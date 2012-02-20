
/** @delete_class jasper */

/** @class_declaration megarOil */
//KLO///////////////////////////////////////////////////////////////
//// MEGAROIL //////////////////////////////////////////////
class megarOil extends modImpresion {
	function megarOil( context ) { modImpresion ( context ); }
	function vencimiento(nodo:FLDomNode, campo:String):String {
		return this.ctx.megarOil_vencimiento(nodo, campo);
	}
	function desgloseIva(nodo:FLDomNode, campo:String):String {
		return this.ctx.megarOil_desgloseIva(nodo, campo);
	}
	function desgloseBaseImponible(nodo:FLDomNode, campo:String):String {
		return this.ctx.megarOil_desgloseBaseImponible(nodo, campo);
	}
	function desgloseRecargo(nodo:FLDomNode, campo:String):String {
		return this.ctx.megarOil_desgloseRecargo(nodo, campo);
	}
	function desgloseTotal(nodo:FLDomNode, campo:String):String {
		return this.ctx.megarOil_desgloseTotal(nodo, campo);
	}
	function lanzarJRXML(informe:String,modelo:String,argumentos:String) {
		return this.ctx.megarOil_lanzarJRXML(informe,modelo,argumentos);
	}
	function lanzarInforme(cursor:FLSqlCursor, nombreInforme:String, orderBy:String, groupBy:String, etiquetas:Boolean, impDirecta:Boolean, whereFijo:String, nombreReport:String, numCopias:Number, impresora:String, pdf:Boolean) {
		return this.ctx.megarOil_lanzarInforme(cursor, nombreInforme, orderBy, groupBy, etiquetas, impDirecta, whereFijo, nombreReport, numCopias, impresora, pdf);
	}
	function sysexec(comando:String):Array {
		return this.ctx.megarOil_sysexec(comando);
	}
}
//// MEGAROIL ///////////////////////////////////////////////
//KLO///////////////////////////////////////////////////////////////

/** @class_definition megarOil */
//KLO///////////////////////////////////////////////////////////////
//// MEGAROIL /////////////////////////////////////////////////
/** \D
Funci�n para campos calculados que obtiene los vencimientos de una factura de cliente
OJO: HACE LO MISMO QUE LA PADRE PERO SEPARA M�S LA FECHA DE LA CANTIDAD DE COBRO.
 */
function megarOil_vencimiento(nodo:FLDomNode, campo:String):String
{
	var util:FLUtil = new FLUtil();
	if (!sys.isLoadedModule("flfactteso")) {
		var codPago:String;
		var fecha:String;
		if (campo == "reciboscli"){
			codPago = nodo.attributeValue("facturascli.codpago");
			fecha = nodo.attributeValue("facturascli.fecha");
		}
		else if (campo == "recibosprov"){
			codPago = nodo.attributeValue("facturasprov.codpago");
			fecha = nodo.attributeValue("facturasprov.fecha");
		}

		var qryDias:FLSqlQuery = new FLSqlQuery();
		var vencimientos:String = "";
		with(qryDias){
			setTablesList("plazos");
			setSelect("dias");
			setFrom("plazos");
			setWhere("codpago = '" + codPago + "' ORDER BY dias");
		}
		if (!qryDias.exec())
			return "";

		while (qryDias.next()) {
			if (vencimientos != "")
				vencimientos += ", ";
			vencimientos += util.dateAMDtoDMA(util.addDays(fecha, qryDias.value(0)));
		}
		var res:String = this.iface.reemplazar(vencimientos, '-', '/')
				return res;
	}

	var tabla:String;
	var idFactura:FLDomNode;

	if (campo == "reciboscli"){
		tabla = "reciboscli";
		idFactura = nodo.attributeValue("facturascli.idfactura");
	}
	else if (campo == "recibosprov"){
		tabla = "recibosprov";
		idFactura = nodo.attributeValue("facturasprov.idfactura");
	}

	var qryRecibos:FLSqlQuery = new FLSqlQuery();
	var vencimientos:String = "";
	with (qryRecibos) {
		setTablesList(tabla);
		setSelect("fechav, importe");
		setFrom(tabla);
		setWhere("idfactura = '" + idFactura + "' ORDER BY fechav");
	}
	if (!qryRecibos.exec())
		return "";

	var fecha:String;
	while (qryRecibos.next()) {
		fecha = util.dateAMDtoDMA(qryRecibos.value(0));
		if (vencimientos != "")
			vencimientos += "\n";
		vencimientos += this.iface.reemplazar(fecha.substring(0,10), '-', '/');
		vencimientos += ":   " + util.formatoMiles(util.roundFieldValue(qryRecibos.value("importe"), "reciboscli", "importe"));
	}
	//var res:String = this.iface.reemplazar(vencimientos, '-', '/')
	//res = this.iface.reemplazar(res, '.', ',')
	return vencimientos;
}

function megarOil_desgloseIva(nodo:FLDomNode, campo:String):String
{
	this.iface.porIVA(nodo, campo);
	return this.iface.__desgloseIva(nodo, campo);
}

function megarOil_desgloseBaseImponible(nodo:FLDomNode, campo:String):String
{
	this.iface.porIVA(nodo, campo);
	return this.iface.__desgloseBaseImponible(nodo, campo);
}

function megarOil_desgloseRecargo(nodo:FLDomNode, campo:String):String
{
	this.iface.porIVA(nodo, campo);
	return this.iface.__desgloseRecargo(nodo, campo);
}


function megarOil_desgloseTotal(nodo:FLDomNode, campo:String):String
{
	this.iface.porIVA(nodo, campo);
	return this.iface.__desgloseTotal(nodo, campo);
}

function megarOil_sysexec(comando:String):Array
{
	var res:Array = [];
	Process.execute(comando);
	if (Process.stderr != "") {
		res["ok"] = false;
		res["salida"] = "!" + Process.stderr + "(" + Process.stdout + ")";
	} else {
		res["ok"] = true;
		res["salida"] = Process.stdout;
	}
	return res["salida"];
}

function megarOil_lanzarJRXML(informe:String,modelo:String,argumentos:String)
{
	var util:FLUtil = new FLUtil();
	debug("Lanzamos el informe '" + informe + "' modelo '" + modelo + "'");
	debug("argumentos:" + argumentos);
	util.createProgressDialog ("Imprimiendo informe '" + informe + "' modelo '" + modelo + "'", 100)
	util.setProgress(1);
	var curColaImpresion:FLSqlCursor = new FLSqlCursor("jrpt_colaimpresion");
	curColaImpresion.setModeAccess(curColaImpresion.Insert);
	curColaImpresion.refresh();
	curColaImpresion.setValueBuffer("codinforme",informe);
	curColaImpresion.setValueBuffer("modelo",modelo);
	curColaImpresion.setValueBuffer("argumentos",argumentos);
	curColaImpresion.setValueBuffer("estado","Pendiente");
	curColaImpresion.setValueBuffer("peticion","imprimir");
	curColaImpresion.commitBuffer();
	var id = curColaImpresion.valueBuffer("id");
	util.setProgress(2);
	var estado = "Pendiente";
	var n = 0;
	var n1 = 0;
	var mInicio:Date = new Date();
	var mFin:Date = new Date();
	while(estado == "Pendiente") {
		if (n1!=n) {
			estado = util.sqlSelect("jrpt_colaimpresion","estado","id = '" + id + "'");
			n1=n;
		}
		mFin = new Date();
		n = (mFin.getTime() - mInicio.getTime()) / 200;
		util.setProgress(3+n%10);

	}

	mInicio = new Date();
	while(estado == "Procesando") {
		if (n1!=n) {
			estado = util.sqlSelect("jrpt_colaimpresion","estado","id = '" + id + "'");
			n1=n;
		}
		mFin = new Date();
		n = (mFin.getTime() - mInicio.getTime()) / 200;
		util.setProgress(13+n%80);
	}
	util.setProgress(95);
	if (estado != "Finalizado")
	{
		txt_msg = util.sqlSelect("jrpt_colaimpresion","mensaje","id = '" + id + "'");
		MessageBox.information("Ocurri� un error inesperado al imprimir (estado="+estado+")"+"\n\n"+txt_msg , MessageBox.Ok, MessageBox.NoButton);

		util.destroyProgressDialog();
		return;
	}
	var urlpdf = util.sqlSelect("jrpt_colaimpresion","urlpdf","id = '" + id + "'");
	var rutaImpresion:String;
	rutaImpresion = util.readSettingEntry("scripts/flfactinfo/RutaServer", "");
	var rutaVisor:String;
	rutaVisor = util.readSettingEntry("scripts/flfactinfo/RutaVisor", "");
	var rutaArchivo:String=rutaImpresion.toString()+urlpdf.toString();
	rutaArchivo.toString();
	var rutaArchivo2:String=rutaArchivo;

	if (util.readSettingEntry("scripts/flfactinfo/CambiarBarras",  0)==1)
	{
		var i:Number=0;
		for (i=0;i<32;i++) {
			rutaArchivo2=rutaArchivo2.replace(new RegExp("/"),"\\");
		}
	}
	else
	{
		rutaArchivo2=rutaArchivo;
	}
	debug(rutaVisor);
	debug(rutaArchivo);
	debug(rutaArchivo2);
	debug(this.iface.sysexec([rutaVisor,rutaArchivo2]));
	util.destroyProgressDialog();


	MessageBox.information("Impresi�n terminada.", MessageBox.Ok, MessageBox.NoButton);
	return;

}

/** \D
Lanza un informe
@param	cursor: Cursor con los criterios de b�squeda para la consulta base del informe
@param	nombreinforme: Nombre del informe
@param	orderBy: Cl�usula ORDER BY de la consulta base
@param	groupBy: Cl�usula GROUP BY de la consulta base
@param	etiquetas: Indicador de si se trata de un informe de etiquetas
@param	impDirecta: Indicador para imprimir directaemnte el informe, sin previsualizaci�n
@param	whereFijo: Sentencia where que debe preceder a la sentencia where calculada por la funci�n
\end */
function megarOil_lanzarInforme(cursor:FLSqlCursor, nombreInforme:String, orderBy:String, groupBy:String, etiquetas:Boolean, impDirecta:Boolean, whereFijo:String, nombreReport:String, numCopias:Number, impresora:String, pdf:Boolean)
{
	debug("KLO--> lanzarInforme 1");

	var util:FLUtil = new FLUtil();
	existeJrxml = util.sqlSelect("flfiles","nombre","nombre = '" + nombreInforme + ".jrxml'");
	existeKut = util.sqlSelect("flfiles","nombre","nombre = '" + nombreInforme + ".kut'");
	solicitaJrxml = util.sqlSelect("jrpt_declararinforme","solicitajrxml","codinforme = '" + nombreInforme + "'");
	solicitaKut = util.sqlSelect("jrpt_declararinforme","solicitakut","codinforme = '" + nombreInforme + "'");
	debug(nombreInforme);

	var dialog:Dialog = new Dialog;
	dialog.okButtonText = util.translate("scripts","Aceptar");
	dialog.cancelButtonText = util.translate("scripts","Cancelar");
	var bgroup:GroupBox = new GroupBox;
	dialog.add(bgroup);

	var cursorModelos:FLSqlCursor = new FLSqlCursor("jrpt_modeloinforme");
	cursorModelos.select("codinforme = '"+nombreInforme+"'");
	var i:Number = 0;
	var lstRB:Array=[];
	var lstRBcod:Array=[];

	while (cursorModelos.next()) {
		var rB:Object;
		rB = new RadioButton;
		bgroup.add(rB);
		rB.text = cursorModelos.valueBuffer("descripcion");
		if( i == 0)
			rB.checked = true;
		else
			rB.checked = false;
		lstRB[i]=rB;
		lstRBcod[i]=cursorModelos.valueBuffer("nombre");
		i++;


	}
	if (existeJrxml)
	{
		if (i==0 || solicitaJrxml)
		{
			rB = new RadioButton;
			bgroup.add(rB);
			rB.text = "Informe JasperReports";
			lstRB[i]=rB;
			lstRBcod[i]=nombreInforme;
			i++;
		}
	}

	if (existeKut)
	{
		if (i==0 || solicitaKut)
		{
			rB = new RadioButton;
			bgroup.add(rB);
			rB.text = "Informe AbanQ";
			lstRB[i]=rB;
			lstRBcod[i]="KUT";
			i++;
		}
	}

	var numOpciones = i;
	var opcionElegida = -1;
	if (numOpciones==0)
	{
		MessageBox.information("No hay ning�n modelo asociado a este informe. No se puede imprimir", MessageBox.Ok, MessageBox.NoButton);
		return;
	}
	else if (numOpciones==1)
	{
		opcionElegida = 0;
	}
	else
	{
		if(!dialog.exec()) return;
		for (i=0;i<numOpciones;i++)
		{
			rB =  lstRB[i];
			if (rB.checked)
			{
				opcionElegida = i;
				break;
			}
		}
	}
	var q:FLSqlQuery = this.iface.establecerConsulta(cursor, nombreInforme, orderBy, groupBy, whereFijo);

	var modelo = lstRBcod[opcionElegida];
	if (modelo != "KUT") {
		var argumentos = "";
		if(q.where())
		{
			argumentos += "WHERE=" +q.where()+"\n";
		}
		else
		{
			argumentos += "WHERE=" + "1 = 1";
		}
		if(q.orderBy())
		{
			argumentos += "ORDERBY=" +q.orderBy()+"\n";
		}
		else
		{
			argumentos += "ORDERBY=" + "1";
		}
		this.iface.lanzarJRXML(nombreInforme,modelo,argumentos);
		return;
	}

	/////////////////////////////////////////////////
	////////////////////////////////////////////////
	//KLO. A PARTIR DE AQUI ES LO OFICIAL
	return this.iface.__lanzarInforme(cursor, nombreInforme, orderBy, groupBy, etiquetas, impDirecta, whereFijo, nombreReport, numCopias, impresora, pdf);
}
//// MEGAROIL /////////////////////////////////////////////////
//KLO//////////////////////////////////////////////////////////////

