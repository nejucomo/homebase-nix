fn main() {
    // `assets/` is not a cargo source, so this only builds if `package.include` is honored.
    print!("{}", include_str!("../assets/greeting.txt"));
}
