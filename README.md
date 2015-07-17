PHPTestFest
===========

##Começando

Clone o repositório e inicie os submódulos

```bash
$ git clone git@github.com:royopa/PHPTestFest.git
$ git submodule init
$ git submodule update
```

Inicie a máquina virtual com o Vagrant

```bash
$ vagrant up
$ vagrant ssh
```

Compile o PHP com os testes

```bash
$ cd php-src
$ ./buildconf
$ ./configure
$ make
$ make test
```

No fim, responder com Y para mandar os relatórios

##Gerando LCOV code coverage report

Siga os próximos passos para gerar um relatório de cobertura de código como o 
abaixo:

![](lcov_report.png)

Rode os seguintes comandos:

```bash
$ ./configure --enable-gcov # configura o php habilitando essa biblioteca 
$ make
```

Para gerar um relatório de cobertura de um teste, é necessário executar o comando

```bash
$ make lcov TESTS=teste/a/ser/executado
```

O relatório em HTML fica disponível em lcov_html/index.html. Assim, é só comparar
o seu relatório de cobertura com o [relatório do PHP QA](http://gcov.php.net/PHP_HEAD/lcov_html/index.php)
para ver se o seu teste testou algo que não era testado antes.

Fonte para geração desse repositório:
[https://gist.github.com/rogeriopradoj/68f4372483814cba62d5](https://gist.github.com/rogeriopradoj/68f4372483814cba62d5)

