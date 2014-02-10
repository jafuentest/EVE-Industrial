function updateSystems()
{
  var region = $('#region').find(":selected").val();
  $.getJSON('/regions/'+region+'/systems').success(function(data)
  {
    $("#system").empty();
    $("#system").append('<option value="">Whole Region</option>');
    $.each(data, function(i,item)
    {
      var option = '<option value="'+item.id+'">'+item.name+'</option>';
      $("#system").append(option);
    });
  });
}
