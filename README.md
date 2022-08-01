# Inochi Creator builder

This is my reference building process for inochi-creator. I built this with the 
purpose of using it as reference to eventually package the software into COPR.

Versions of the software generated using this scripts are not supported by the 
upstream project.

If you use Fedora 36+ and don't mind using the software without support or the 
branding assets, check out https://copr.fedorainfracloud.org/coprs/grillo-delmal/inochi2d/

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

The result should end up in the `build_out/inochi` folder

## Run

Go into the `build_out/inochi` folder and run the `./inochi-creator` binary 
or use the `run.sh` script.

## Debug

If you want to run a debug version of the application, run the `deploy.sh` 
and `run.sh` scripts with the `DEBUG=1` env variable.

```sh
DEBUG=1 ./deploy.sh
DEBUG=1 ./run.sh
```