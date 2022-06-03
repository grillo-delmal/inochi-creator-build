# Inochi Creator builder

I built this with the purpose of using it as reference to package the software into COPR in the future for Fedora 36+.

This is my reference building process for inochi-creator, versions generated using this scripts are not supported by the upstream project.

## Dependencies

You just need podman to run this, should work fine with Docker too with some tweaks.

Remember to initalize the repository submodules before continuing

```sh
git submodule update --init --recursive
```

## Build

Just run the deploy script

```sh
./deploy.sh
```

You can also build with debug flags by modifying the `DEBUG` env variable

```sh
DEBUG=1 ./deploy.sh
```

The result should end up in the `build_out/inochi` folder

## Run

Go into the `build_out/inochi` folder and run the `./inochi-creator` binary.
