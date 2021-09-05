# Paper Backup for pass

An extension for [pass(1)](https://www.passwordstore.org/) - the standard Unix password manager - to backup all passwords to paper (being aware of the risks).

## Install

    make install

The extension is installed into `~/.password-store/.extensions/` and must be enabled by setting the `PASSWORD_STORE_ENABLE_EXTENSIONS` environment variable:

    export PASSWORD_STORE_ENABLE_EXTENSIONS=true 

This extension is only tested for **macOS**.

### Uninstall

    make uninstall

## Output

`pass paper` prints only content above a separator (default separator is `=======`): all lines above the
separator are printed, all lines below the separator are **not** printed.

### Example Output

    ---- private/example.com -------------------------------------------------
      mysecretpassword123
      username: joe

    ---- work/example.org ----------------------------------------------------
      supersecretpassword123
      user: joe

## Usage

:warning: Always pipe output to `lp(1)` to avoid having password in plain text in a file.

Print all passwords with

    pass paper | lp

Print all passwords in a printer-friendly format with

    pass paper | pr | lp

Print all password from 'folder' with

    pass paper folder | lp

Print password 'folder/password' with

    pass paper folder/password | lp

Print all passwords with content above separator `<<<<<<<` (7 chars minimum) with

    pass paper -s '<' | lp

