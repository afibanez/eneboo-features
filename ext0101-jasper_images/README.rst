Extensión JasperImages para Eneboo
=================================================

Esta extensión añade la posibilidad de usar dinamicamente imagenes en JasperReports.


Uso
---------------------

Para poder usar JasperImages, necesitaremos:
	* La extensión jasper de Gestiweb instalada y funcionando
	* Todos los clientes que usen JasperImages, deben tener permiso de lectura y escritura en la carpeta compartida que usa la extensión Jasper
	* Si se quiere usar JasperImages, en el proyecto, además de las carpetas ya existentes "reports", "templates" i "tmp", **se deberá crear manualmente** una carpeta con el nombre "images"
	
JasperImages utiliza la misma configuración de servidor que la extensión Jasper, por lo que si ya estaba configurado, no deberemos preocuparnos de nada.
En caso contrario, deberemos configurar la ruta a la carpeta compartida y el tipo de barra o contrabarra en la configuración de la extensión Jasper.

Al instalar JasperImages, en la carpeta facturación/informes/forms nos aparecerá el fichero jasperImages_EJEMPLO.ui , donde podemos ver una pequeña explicación de uso.

Básicamente en ese fichero tenemos un layout con dos controles:
	* jasper_image (un layout vacio donde se colocará la imagen)
	* jasper_image_button (un boton que ejecutará el cambio de imagen)
	
El uso más sencillo de la extensión es:
	* Crear en la tabla donde queramos que vaya una imagen, el campo 'jasper_image', un string de 250 que puede estar vacio/null, y que se usará para guardar la ruta de la imagen.
	* Copiar los controles del ejemplo al formulario de registro que queramos añadirle la imagen, y en el init de éste escribir::
		
		flfactinfo.iface.pub_controlImagen(this);
	
Y eso es todo. La extensión le dará funcionalidad a los controles que hemos añadido, y se encargará de todo. Esta funcion devuelve true, o false en el caso de cualquier fallo.