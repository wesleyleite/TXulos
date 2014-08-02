TXulos
======

micro declarative script to automate tests

## What is it?

Is not a tool, it is a fun because Shell Script is fun.

I always dreamed to create a programming language, but,
never had a purpose or thought it would be advantageous
to someone or to me, when I began the implementation of
scripts txulos realized it would be possible to do
something close to it, an interpreter of options for
formatting commands to wget.

## How do i use?
Using your favorite editor, you can write simple script
as follows

### exemplo de script
  this is an example implementation of a login mechanism,
  this can run alone or be part of something bigger as i show below.

  file: login.tx

  ```Bash
  #!/bin/txulos
  # COMMENT:
  # start login process
  set target http://www.exemplo.com.br/index.php
  set var username=wesleyleite&password=1234
  set method POST
  run
  ```

  file: logged.tx
  ```Bash
  #!/bin/txulos
  # import file, full path may be required
  import login.tx
  set target http://www.exemplo.com.br/
  set method GET
  set filter grep '([0-9a-f]){32}'
  run
  ```
  after importing the login module, the same will run
  automatically, if successful a cookie will be stored
  in tmp, allowing navigation system, the propouse is to
  reuse.

### How do i run?
On the shell console
  ```Bash
  $ chmod +x logged.tx
  $ ./logged.tx
  ```

### Interactive mode
if you prefer can run in interactive mode, on the console.

  ```Bash
  $ txulos
  TXulos 0.0.1
  help for more information
  >>> set target http://www.exempo.com.br/
  >>> set method GET
  >>> set filter grep -E ([0-9a-fA-F]+){32}
  >>> run
  ```

### HELP
  ```Bash
  >>> help
   - set target <host>
         > set target http://www.example.com
   - set var <variable>
         > set var &username=xulos&password=1234&
   - set method <method>
         > set method POST
   - set wgetoptions <options>
         > set wgetoptions -T 30
   - set useragent   <user-agent-string>
         > set useragent Mozilla/5.0
   - set filter <filter-output-data>
         > set filter html2text
         > set filter grep -Ewo '[a-f0-9]+'
   - attack <variables>
         > attack username
   - unset <var-name|all>
         > unset var username
      remove variable username OR clean all
         > unset all
   - show
         > show
   - import
         > import source.tx
   - run
         > run
   - history <clean>
         > history
         > history clean
   - quit
   ```

## Contributing
    User the branch develop to working

    $ git clone https://github.com/wesleyleite/TXulos.git
    $ cd TXulos
    $ git checkout develop

    tips and bugs please open an issue.
    new feature please open issue.

    if there is a question for finished work, please inform on
    the commit the issue number.

    example

    $ git commit -a -m 'hotfix get param issue#102'

