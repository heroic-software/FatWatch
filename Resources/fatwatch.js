/*global document,$,FatWatch,FatWatchImport */


var FWExportPresets = {
	"Select All":{
		"exportOrder":null,
		"exportDate":true,
		"exportWeight":true,
		"exportTrendWeight":true,
		"exportFat":true,
		"exportFlag0":true,
		"exportFlag1":true,
		"exportFlag2":true,
		"exportFlag3":true,
		"exportNote":true
	},
	"Select None":{
		"exportOrder":null,
		"exportDate":false,
		"exportWeight":false,
		"exportTrendWeight":false,
		"exportFat":false,
		"exportFlag0":false,
		"exportFlag1":false,
		"exportFlag2":false,
		"exportFlag3":false,
		"exportNote":false
	},
	"FatWatch Backup":{
		"exportOrder":null,
		"exportDate":true, "exportDateName":"Date", "exportDateFormat":"y-MM-dd",
		"exportWeight":true, "exportWeightName":"Weight", "exportWeightFormat":"0",
		"exportTrendWeight":false,
		"exportFat":true, "exportFatName":"Body Fat", "exportFatFormat":"0",
		"exportFlag0":true, "exportFlag0Name":"Mark1",
		"exportFlag1":true, "exportFlag1Name":"Mark2",
		"exportFlag2":true, "exportFlag2Name":"Mark3",
		"exportFlag3":true,	"exportFlag3Name":"Mark4",
		"exportNote":true, "exportNoteName":"Note"
	},
	"Hacker's Diet Online":{
		"exportOrder":"date,weight,flag3,flag0,note",
		"exportDate":true, "exportDateName":"Date", "exportDateFormat":"y-MM-dd",
		"exportWeight":true, "exportWeightName":"Weight", "exportWeightFormat":"1",
		"exportTrendWeight":false,
		"exportFat":false,
		"exportFlag0":true, "exportFlag0Name":"Flag",
		"exportFlag1":false,
		"exportFlag2":false,
		"exportFlag3":true, "exportFlag3Name":"Rung",
		"exportNote":true, "exportNoteName":"Comment"
	},
	"TrueWeight":{
		"exportOrder":"date,weight",
		"exportDate":true, "exportDateName":"Date", "exportDateFormat":"y-MM-dd",
		"exportWeight":true, "exportWeightName":"Weight", "exportWeightFormat":"4",
		"exportTrendWeight":false,
		"exportFat":false,
		"exportFlag0":false,
		"exportFlag1":false,
		"exportFlag2":false,
		"exportFlag3":false,
		"exportNote":false
	}
};


function performTextSubstitution() {
	var title = 'FatWatch on ' + FatWatch.deviceName;
	document.title = title;
	$("#bigtitle").text(title);
	$(".deviceModel").text(FatWatch.deviceModel);
	$("#copyright").text(FatWatch.copyright);
}


function configureTabs() {
	var defaultTab;
	var tabContainers = $("#tabs > div");
	
	if (document.location.hash) {
		defaultTab = '[href=' + document.location.hash + ']';
	} else {
		defaultTab = ':first';
	}
	
	$("a.tablink").click(function (event) {
						 tabContainers.hide().filter(this.hash).show();
						 $("a.tablink")
						 .removeClass('selected')
						 .filter('[href=' + this.hash + ']')
						 .addClass('selected');
						 }).filter(defaultTab).click();
}


function updateSelectOptions(formats, eltId) {
	var selectElt = document.getElementById(eltId);
	while (selectElt.lastChild !== null) {
		selectElt.removeChild(selectElt.lastChild);
	}
	for (var i in formats) {
		var optionInfo = formats[i];
		var optionElt = document.createElement("option");
		optionElt.value = optionInfo.value;
		optionElt.innerHTML = optionInfo.label;
		selectElt.appendChild(optionElt);
	}
}


function updateFormValues(defaults) {
	for (var eltId in defaults) {
		var value = defaults[eltId];
		var elt = document.getElementById(eltId);
		if (elt === null) {
			console.log("Warning: no such element " + eltId);
		}
		else if (elt.type === "checkbox") {
			elt.checked = value;
		}
		else {
			elt.value = value;
		}
	}
}


function homeReady() {
	// Input Validation
	$("#importFileData").change(function (event) {
		$("#sendButton").get(0).disabled = !this.value;
	}).change();
	
	// Text Substitution
	performTextSubstitution();
	var mailURL = 'mailto:help@fatwatchapp.com?subject=FatWatch%20(' +
	FatWatch.version + ')';
	$("#sendButton").attr('value', 'Send to ' + FatWatch.deviceModel);
	$("#helpMailLink").attr('href', mailURL);
	
	configureTabs();
	
	// Export Form Formats
	updateSelectOptions(FatWatch.dateFormats, 'exportDateFormat');
	updateSelectOptions(FatWatch.weightFormats, 'exportWeightFormat');
	updateSelectOptions(FatWatch.fatFormats, 'exportFatFormat');
	
	// Export Form Defaults
	updateFormValues(FatWatch.exportDefaults);
	
	// Preset Links
	var presetContainer = document.getElementById('exportPresets');
	for (var presetName in FWExportPresets) {
		presetContainer.appendChild(document.createTextNode(", "));
		var link = document.createElement('a');
		link.href = '#';
		link.appendChild(document.createTextNode(presetName));
		presetContainer.appendChild(link);
	}
	
	var exportCheckboxes = $('#export form :checkbox');
	
	exportCheckboxes.change(function(){
		var nameElt = document.getElementById(this.id + 'Name');
		var formatElt = document.getElementById(this.id + 'Format');
		nameElt.disabled = !this.checked;
		if (formatElt) { formatElt.disabled = !this.checked; }
		var label = $('#export label[for=' + this.id + ']');
		if (this.checked) {
			label.removeClass('disabled');
		} else {
			label.addClass('disabled');
		}
   }).change();

	$('#exportPresets>a').click(function(event){
								var defaults = FWExportPresets[this.innerText];
								if (defaults) {
								updateFormValues(defaults);
								} else {
								updateFormValues(FatWatch.exportDefaults);
								}
								exportCheckboxes.change();
								event.preventDefault();
								});
}


function importReady() {
	performTextSubstitution();
	
	$('select').each(function () {
		 if (this.id.indexOf("Format") > 0) { return; }
		 var columns = FatWatchImport.columns;
		 for (var i in columns) {
			 var optionElt = document.createElement("option");
			 optionElt.innerHTML = columns[i];
			 optionElt.value = parseInt(i,10) + 1;
			 this.appendChild(optionElt);
		 }
	 }).change(function(){
		var samples = FatWatchImport.samples;
		if (this.value > 0) {
			var array = samples[String(this.value - 1)];
			var text = array.join('<br/>');
			$("#" + this.id + "Format").attr("disabled", false);
			$("#" + this.id + "Preview").html(text);
		} else {
			$("#" + this.id + "Format").attr("disabled", true);
			$("#" + this.id + "Preview").text('');
		}
	});
	
	updateFormValues(FatWatchImport.importDefaults);
	updateSelectOptions(FatWatch.dateFormats, 'importDateFormat');
	updateSelectOptions(FatWatch.weightFormats, 'importWeightFormat');
	updateSelectOptions(FatWatch.fatFormats, 'importFatFormat');
	
	$('select').change();
}
