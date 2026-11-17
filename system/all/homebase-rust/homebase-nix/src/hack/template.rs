//! The template system _and_ template data for `homebase-nix hack`

use std::borrow::Cow;
use std::path::Path;
use std::str::FromStr;
use std::sync::LazyLock;

use include_dir::{Dir, DirEntry, File, include_dir};
use oxford_join::OxfordJoin as _;
use regex::{Captures, Regex};
use yaffa::{WrapErr as _, format_err};

static EXPANSION_TAG: LazyLock<Regex> =
    LazyLock::new(|| Regex::new(r#"HACKNOW\{NAME(_UNDERS)?\}"#).unwrap());

const TEMPLATE_SUFFIX: &str = ".hacknow-template";
const TEMPLATES: Dir<'_> = include_dir!("$CARGO_MANIFEST_DIR/templates");

/// A template for a given project type
#[derive(Copy, Clone, derive_more::Debug)]
pub struct Template {
    /// The name of the template
    pub name: &'static str,
    #[debug(skip)]
    srcroot: &'static Dir<'static>,
}

impl Template {
    /// Names of known templates:
    pub fn names() -> impl Iterator<Item = &'static str> {
        TEMPLATES
            .entries()
            .iter()
            .map(|e| e.path().file_name().unwrap().to_str().unwrap())
    }

    /// Describe the names of all known templates
    pub fn describe_names() -> String {
        format!(
            "known templates: {}",
            Self::names().collect::<Vec<_>>().oxford_or()
        )
    }

    /// Expand this template into `dest`, using the last path component as project name
    pub fn expand_into(self, dest: &Path) -> yaffa::Result<&str> {
        let name = file_name(dest)?;
        self.expand_into_named(dest, name)
    }

    /// Expand this template into `dest`, using the given project `name`
    pub fn expand_into_named<'n>(self, dest: &Path, name: &'n str) -> yaffa::Result<&'n str> {
        log::info!(
            "template {:?} expanding {:?} into {}",
            self.name,
            name,
            dest.display(),
        );
        self.srcroot.expand_fs(dest, name)?;
        Ok(name)
    }
}

impl FromStr for Template {
    type Err = yaffa::Error;

    fn from_str(s: &str) -> yaffa::Result<Self> {
        let srcroot = TEMPLATES
            .get_dir(s)
            .ok_or_else(|| format_err!("{}", Template::describe_names()))?;

        let name = file_name(srcroot.path())?;
        Ok(Self { name, srcroot })
    }
}

trait ExpandFs {
    fn expand_fs<P>(&self, dest: P, projname: &str) -> yaffa::Result<()>
    where
        P: AsRef<Path>;
}

impl ExpandFs for DirEntry<'static> {
    fn expand_fs<P>(&self, dest: P, projname: &str) -> yaffa::Result<()>
    where
        P: AsRef<Path>,
    {
        use DirEntry::*;

        log::debug!(
            "project {projname:?} expanding {:?} into {:?}",
            self.path(),
            dest.as_ref().display()
        );
        match self {
            Dir(dir) => dir.expand_fs(dest, projname),
            File(file) => file.expand_fs(dest, projname),
        }
    }
}

impl ExpandFs for Dir<'static> {
    fn expand_fs<P>(&self, dest: P, projname: &str) -> yaffa::Result<()>
    where
        P: AsRef<Path>,
    {
        let dest = dest.as_ref();
        fs_err::create_dir(dest)?;

        for entry in self.entries() {
            let cname_raw = file_name(entry.path())?;
            let cname = expand_str(cname_raw, projname);
            entry.expand_fs(dest.join(cname.as_ref()), projname)?;
        }

        Ok(())
    }
}

impl ExpandFs for File<'static> {
    fn expand_fs<P>(&self, dest: P, projname: &str) -> yaffa::Result<()>
    where
        P: AsRef<Path>,
    {
        let dest = dest.as_ref();
        let fname = file_name(dest)?;

        if let Some(destname) = fname.strip_suffix(TEMPLATE_SUFFIX) {
            log::debug!("expanding {fname:?} into {:?}", dest.display());
            let tmpltext = self.contents_utf8().unwrap();
            let contents = expand_str(tmpltext, projname);
            fs_err::write(dest.parent().unwrap().join(destname), contents.as_ref())?;
        } else {
            fs_err::write(dest, self.contents())?;
        }
        Ok(())
    }
}

fn file_name(p: &Path) -> yaffa::Result<&str> {
    p.file_name()
        .ok_or_else(|| format_err!("missing file name in final path component"))
        .and_then(|n| n.to_str().ok_or_else(|| format_err!("non-utf8 file name")))
        .wrap_err_with(|| format!("path {:?}", p.display()))
}

fn expand_str<'a>(s: &'a str, projname: &str) -> Cow<'a, str> {
    let projunders = projname.replace('-', "_");
    EXPANSION_TAG.replace_all(s, |captures: &Captures<'_>| {
        if captures.get(1).is_some() {
            &projunders
        } else {
            projname
        }
    })
}
