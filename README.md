TXulos
======

micro script para automatizar alguns testes.

## O que é?

Uma brincadeira, é para ser divertido e implementar alguma coisa.

### exemplo de script
  file: login.sqi

  ```Bash
  #!/bin/txulos
  # COMMENT:
  # iniciando processo de login na pagina
  set target http://www.exemplo.com.br/index.php
  set var username=wesleyleite&password=1234
  set method POST
  run
  ```
  file: logged.sqi
  ```Bash
  #!/bin/txulo
  import login.sqi
  # COMMENT:
  # após login pagina pode ser navegada
  set target http://www.exemplo.com.br/
  set method GET
  # ainda existe a possibilidade de adicionar um filtro
  # para extrair informacoes pertinentes
  set filter grep '([0-9a-f]){32}'
  run
  ```

  ```Bash
  $ chmod +x logged.sqi
  $ ./logged.sqi
  ```

  ou
  ```Bash
  $ txulos
  TXulos 0.0.1
  help for more information
  >>> set target http://www.exempo.com.br/
  >>> set method GET
  >>> set filter grep -E ([0-9a-fA-F]+){32}
  >>> run
  ```

### ainda não entendeu?

  Seja criativo.
  É bem menos que um construtor para wget, mas, tem me ajudado em algumas tarefas de teste de aplicações web,
  principalmente quando necessito logar para testar uma váriavel ou um ajax.

  ```Bash
  $ txulos
  ...
  >>> import login.sqi
  >>> show

    Target     : http://www.exemplo.com/index.php
    Var        : username=wesleyleite&password=1234
    Method     : POST
    wgetOptions:
    User-Agent : (TXulos/0.0.1)
    Filter     : tee

  >>> set method GET
  >>> set var id=1&content=webapp-abcde&admin=1
  >>> attack id
  __ id >> +3389=(XXXXX)
  # result  dados são enviados ao rodar o enter.
  # dados originais da variavel sao preservados, de modo que, pode continuar tentando
  # ate obter resultado satisfatório ou desistir.
  __ id >> quit
  >>>
  ```

