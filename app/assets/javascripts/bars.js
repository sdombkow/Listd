$(document).ready(function(){
    function attachListeners(){
        $(".passSetDate").click(function(e){
            var psDate = $(this).attr("psdate");
            console.log(psDate);
            return false;
        });
    }
    attachListeners();
}
