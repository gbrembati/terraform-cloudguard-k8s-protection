# Infinity Next Terraform CLI
The project provides a command line interface for using the API of Infinity Next

## Generating an API Key *(Required)*
If already have an API key from setting up [terraform-provider-infinity-next](https://github.com/CheckPointSW/terraform-provider-infinity-next) then you can skip this section.
1. Go to https://portal.checkpoint.com, navigate to *Global Settings -> API Keys*

2. Create a new API key and select *Infinity Policy* as the service, with *Admin* role, we recommend that you specify a meaningful comment for the key so you could identify them later and avoid mistakes.

3. Store the *Client ID* and *Secret Key* in a secure location, and note there's no way to view the secret key afterward.

## Usage
First, Download and install the CLI found in the latest release.

You could run `inext help` and get all available options and commands.

The CLI requires the same credentials used to configure the provider, there are 3 options to pass these credentials to the CLI:

1. Set the environment variables: `INEXT_REGION`, `INEXT_CLIENT_ID` and `INEXT_ACCESS_KEY` and run `inext <command>`, this is more comfortable for usage right after `terraform apply` since it uses the same environment variables.
   
2. Set credentials using flags `--client-id` (shorthand `-c`) and `--access-key` (shorthand `-k`)
   ```
   inext publish -c $INEXT_CLIENT_ID -k $INEXT_ACCESS_KEY -r us
   ```

3. Create a yaml file at `~/.inext.yaml` with the following content:
   ```
   client-id: <INEXT_CLIENT_ID>
   access-key: <INEXT_ACCESS_KEY>
   region: eu
   ```
   Run `inext <command>` and the CLI would be configured using `~/.inext.yaml` by default, can be set using `inext --config <config-path> <command>`

## Example
```
inext publish && inext enforce
```

## Build
### Requirements
* Go 1.18+

To build the CLI run:
```
go build -o inext
```
You could then install it by running:
```
cp inext /usr/local/bin
```