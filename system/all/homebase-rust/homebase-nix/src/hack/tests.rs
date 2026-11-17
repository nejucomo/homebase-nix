use std::path::Path;

use regex::{Regex, regex};
use test_case::test_case;
use yaffa::ensure;

use crate::hack::Template;

#[test_case("rust", "projectoid", "Cargo.toml", regex!(r#"(?m)^  "projectoid",$"#))]
#[test_case("rust", "my-proj", "my-proj/Cargo.toml", regex!(r#"(?m)^name = "my-proj"$"#))]
#[test_case("rust", "my-proj", "my-proj/src/bin/my-proj.rs", regex!(r#"(?m)^ +my_proj::App::run_main_default\(\)$"#))]
fn spot_check(tmpl: &str, projname: &str, subpath: &str, rgx: &Regex) -> yaffa::Result<()> {
    let tmpl: Template = tmpl.parse()?;

    with_testdir(|testdir| {
        let dest = testdir.join(projname);
        tmpl.expand_into(&dest)?;

        let subdest = dest.join(subpath);
        let content = fs_err::read_to_string(&subdest)?;

        ensure!(
            rgx.is_match(&content),
            "pattern {} not found in path {:?}, contents: {:?}",
            rgx,
            subdest.display(),
            &content
        );

        Ok(())
    })
}

fn with_testdir(f: impl FnOnce(&Path) -> yaffa::Result<()>) -> yaffa::Result<()> {
    let testdir = tempfile::Builder::new()
        .prefix(concat!(env!("CARGO_PKG_NAME"), "."))
        .suffix(".testdir")
        .tempdir()?;

    f(testdir.path()).map_err(|e| {
        let p = testdir.keep();
        e.wrap_err(format!("saved test dir: {:?}", p.display()))
    })
}
