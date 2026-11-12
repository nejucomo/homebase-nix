fn main() {
    // `assets/` is not a cargo source, so this only builds if `package.include` is honored.
    print!("{}", include_str!("../assets/greeting.txt"));
    // Only builds if the nix `env` argument reaches rustc.
    println!("built for {}", env!("DRY_FLAKES_FIXTURE_SYSTEM"));
}
