//! The [hacknow] binary
//!
//! Note, all functionality is in the lib crate [hacknow]; this binary is a `yaffa` wrapper.

fn main() -> yaffa::Result<()> {
    hacknow::run()
}
