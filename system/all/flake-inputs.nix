{
  perSystem = { inputs', ... }: {
    packages = {
      hacknow = inputs'.hacknow.packages.default;
    };
  };
}
