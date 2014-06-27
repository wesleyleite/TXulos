TXulos
======

micro script para automatizar alguns testes.

## O que é?

Uma brincadeira, é para ser divertido e implementar alguma coisa.

## exemplo de script
  ```Bash
  #!/bin/txulos
  # COMMENT:
  # iniciando processo de login na pagina
  set target http://www.exemplo.com.br/index.php
  set var username=wesleyleite&password=1234
  set method POST
  run
  # COMMENT:
  # após login pagina pode ser navegada
  set target http://www.exemplo.com.br/
  set method GET
  set var id=1
  run
  ```
  ou
  
  $ txulos 
  TXulos 0.0.1
  help for more information
  >>> 


