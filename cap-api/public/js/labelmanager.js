$( document ).ready(function () {
    document.getElementById("searchfield").value = "";
    var form = document.getElementById('searchbar');

    if (form.attachEvent) {
        form.attachEvent("submit", processForm);
    } else {
        form.addEventListener("submit", processForm);
    }
    var urlparams = getUrlParameter('search_uuid_tag');
    console.log(urlparams)
    var labels= urlparams.split(",")
    labels.forEach(function(t){
        if(t)
            addLabel(t);
    })
})
function getUrlParameter(sParam) {
    var sPageURL = decodeURIComponent(window.location.search.substring(1)),
        sURLVariables = sPageURL.split('&'),
        sParameterName,
        i;

    for (i = 0; i < sURLVariables.length; i++) {
        sParameterName = sURLVariables[i].split('=');

        if (sParameterName[0] === sParam) {
            return sParameterName[1] === undefined ? true : sParameterName[1];
        }
    }
};

function addLabel(label){
    var labelhtml = "<span value='" + label + "' class='label'>" + label + "<i onclick='remove($(this))' class='labelclose fa fa-times'></i></span>";
    $('#labels').append(labelhtml);
}

function processForm(e) {
    if (e.preventDefault) e.preventDefault();
    var labeldiv= $('#labels');
    var search = document.getElementById("searchfield").value;
    /* do what you want with the form */
    if (search) {
        addLabel(search)
    }


    var query = "";
    for (var i = 0; i < labeldiv.children().length; i++){
        query += $(labeldiv.children()[i]).attr('value');
        if(i < labeldiv.children().length-1){
            query+=",";
        }
    }
    var input = $(this).find("input[name=search_uuid_tag]");
    input.val(query);
    $('form').submit();
    return true;
}

function remove(div){
    div.parent().remove();
}