{
  perSystem = { inputs', ... }: {
    packages = {
      hacknow = inputs'.hacknow.packages.default;
      homebase-rust = inputs'.homebase-rust.packages.default;
    };
  };
}
