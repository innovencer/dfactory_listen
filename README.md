dfactory_listen
===============

¿Qué hace?
---------------
Este script, escucha cambios (creación, modificación o eliminación de archivos) en un directorio del servidor llamado ``"/home/datafactory"`` por defecto y envía un post a las urls:

* http://golazzos.com/webhooks/datafactory/fixture"
* http://golazzos.ngrok.com/webhooks/datafactory/fixture

Se envía un parámetro ``fixture`` en el post, que contiene la ruta del archivo que fue agregado o modificado.

Modo de uso
---------------

* Para iniciar el proceso en background (daemon):

```
$ ./dflistener_control.rb start
```

Es posible iniciar el proceso para que escuche cambios en un directorio específico:

```
$ ./dflistener_control.rb start -- /path/a/esuchar
```

Para iniciar el proceso sin "daemonizarlo", de manera que se puedan ver STDOUT:

```
$ ./dflistener_control.rb run -- /path/a/esuchar
```

* Para detener el proceso:

```
$ ./dflistener_control.rb stop
```