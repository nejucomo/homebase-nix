use crate::options::Options;

#[derive(Debug, Default)]
pub struct App;

impl yaffa::App for App {
    type Options = Options;
}

impl yaffa::RunWith<Options> for App {
    fn run_with(self, _: Options) -> yaffa::Result<()> {
        todo!()
    }
}
