
/** @class_declaration jasperImages */
/////////////////////////////////////////////////////////////////
//// JASPER IMAGES /////////////////////////////////////////////
class jasperImages extends jasper {
	var ruta:String;
	var barras:Number; // 0 = "/" i 1 = "\"
	var container:Object;
    function jasperImages( context ) { jasper ( context ); }
    function controlImagen(container:Object):Boolean {
        return this.ctx.jasperImages_controlImagen(container);
    }
	function cambiarImagen() {
		 return this.ctx.jasperImages_cambiarImagen();
	}
}
//// JASPER IMAGES /////////////////////////////////////////////
/////////////////////////////////////////////////////////////////

/** @class_declaration pubJasperImages */
/////////////////////////////////////////////////////////////////
//// PUB JASPER IMAGES /////////////////////////////////////////
class pubJasperImages extends pubarticuloscomp {
	function pubJasperImages( context ) { pubarticuloscomp( context ); }
	function pub_controlImagen(container:Object):Boolean {
        return this.controlImagen(container);
    }
}
//// PUB JASPER IMAGES /////////////////////////////////////////
/////////////////////////////////////////////////////////////////

/** @class_definition jasperImages */
/////////////////////////////////////////////////////////////////
//// JASPER IMAGES /////////////////////////////////////////////
function jasperImages_controlImagen(container:Object):Boolean
{
	// #byAngel
	var util:FLUtil = new FLUtil;

	debug("Inicializando JasperImages...");

	this.iface.container = container; //Guardem el contenidor, perquè cambiarImagen() pugui utilitzar-lo
	var field = "jasper_image";

	try {
		// Miramos las variables de jasper para saber donde colocar las imagenes
		this.iface.ruta = util.readSettingEntry("scripts/flfactinfo/RutaServer");

		var cambio = util.readSettingEntry("scripts/flfactinfo/CambiarBarras");
		if (!cambio && isNaN(cambio)) this.iface.barras = 0;
		else this.iface.barras = cambio;

		// Conectamos el botón de donde venimos con la función para cambiar la imagen
		connect(container.child(field+"_button"), "clicked()", this, "iface.cambiarImagen()");

		// Ponemos la imagen en el caso de que exista
		var imagen = container.cursor().valueBuffer(field);

		if (imagen && imagen != ""){
			var pathFichero:String;
			if (this.iface.barras == 0) pathFichero = this.iface.ruta+"/"+sys.nameBD()+"/images/"+imagen;
			else pathFichero = this.iface.ruta+"\\"+sys.nameBD()+"\\images\\"+imagen;

			var pixmap:QPixmap = new QPixmap(pathFichero);
			container.child(field).setPixmap(pixmap);
		}
    }
    catch ( e ) {
		return false;
    }

	debug("JasperImages inicializado correctamente.");
	return true;
}

function jasperImages_cambiarImagen()
{
	var util:FLUtil = new FLUtil;

	var container = this.iface.container;
	var field = "jasper_image";

	// Primero, abrimos el formulario de seleccion de imagen #byAngel
	var pathFichero:String = FileDialog.getOpenFileName("Images (*.png *.PNG *.xpm *.XPM *.jpg *.JPG *.jpeg *.JPEG *.gif *.GIF)", "Seleccione imagen");
	if (!pathFichero) {
		return false;
	}

	var table = container.cursor().table();
	var keyfield = container.cursor().primaryKey();
	var id = container.cursor().valueBuffer(keyfield);

	// Seguidamente, guardamos la imagen en el directorio compartido de JR, y en el campo jasper_image de la tabla
	var nuevoNombre:String = table+"_"+id+".png";
	container.cursor().setValueBuffer(field,nuevoNombre);

	var nuevoPath:String;
	if (this.iface.barras == 0) nuevoPath = this.iface.ruta+"/"+sys.nameBD()+"/images/"+nuevoNombre;
	else nuevoPath = this.iface.ruta+"\\"+sys.nameBD()+"\\images\\"+nuevoNombre;

	try {
        var image:QImage = new QImage(pathFichero);
		image.save(nuevoPath,"PNG");
    }
    catch ( e ) {
		container.cursor().setValueBuffer(field,"");
		MessageBox.warning(util.translate("scripts", "Hubo un error al actualizar la imagen:\n" + e), MessageBox.Ok, MessageBox.NoButton);
		return false;
    }

	// Para finalizar, actualizamos la imagen en el formulario
	var pixmap:QPixmap = new QPixmap(nuevoPath);
	container.child(field).setPixmap(pixmap);
}

//// JASPER IMAGES /////////////////////////////////////////////
////////////////////////////////////////////////////////////////

