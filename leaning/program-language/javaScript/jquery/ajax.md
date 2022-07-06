# Jquery.Ajax的使用方法
1.Get

 $('.manager_republish.notVIP').click(function () {
        $.ajax({
            async: false,
            type: "get",
            url: '@Url.Action("NeedVipPermisson", "MessageDialog", new { area = "Default", Title = "非VIP企业", Content = "此职位不属于VIP企业，不能重新发布" })',
            success: function (data) { ShowMessageModelDialog(data)},
            error: function (jqXHR, textStatus, errorThrown) {
                alert("出错了" + textStatus + " " + errorThrown);
            }
        });
    });
 

2.Post

$.ajax({
        async: false,
        dataType: "JSON",
        contentType: "Application/json",
        type: "post",
        url: "../../Control/Webservice/changeInfo.asmx/Insertdata",
        data: "{'user_Name':'"+user_name+"','stu_id':'" + stu_id.val() + "','stu_name':'" + stu_name.val() + "','stu_major':'" + stu_major.val()
            + "','stu_dept':'"+stu_dept.val()+"'}",
        suceess: function(data) {
            alert(data.d);
        },
        error: function() {
            alert("chucuole");
        }
    });
 

3.Get的优雅用法

                $.getJSON('/Enterprise/Default/DeleteJob?id=' + key, 
                   function (data) {
                    if (data.isSuccess) { $('.Jobkey' + key).remove(); }
                    else {
                        alert(data.msg);
                    }
                });
 4.post的另一种用法

 function ReloadCities() {
                var $ddlCity = $("#ddlCity");
                var selec = $("#ddlProvince").val();
                if (selec) {
                    $ddlCity.find("option").remove();
                    var url = "@(Url.Action("CityListByProvinceId", "Enterprise", new { area = "Admin" }))";
                    $.post(url, { 'id': selec }, function (data) {
                        for (var i = 1; i < data.length; i++) {
                            $($ddlCity).append($("<option></option>").text(data[i].addressName).val(data[i].addressId))
                        }
                    }, "json");
                }
                else {
                    $ddlCity.find("option").remove();
                    $("<option></option>").val("").text("--请选择--").appendTo($ddlCity);
                }
            }
5.load

$('#tabs-2').load('Temp_login.html', function (responseText, textStatus) {
    if (textStatus === "success") {
        $('#tabs-2 .form-actions .primary').attr("id", "tea_login");
        $("#tea_login").click(tea);
        
    }
6.ajax注意事项

function SendResume(jobId) {
    var resumeSendInfo = {};
    resumeSendInfo.Subject = $("#post_resume_subject").val();
    resumeSendInfo.Body = $("#post_resume_content").val();
    $.ajax({
        url: '/Resume/Ajax/Send?Id='+jobId,
        data: JSON.stringify(resumeSendInfo),
        type: 'post',
        dataType: "json",
        contentType: 'application/json;charset=UTF-8',
        cache: false,
        beforeSend: function(){
            $("#btnSendResume").attr("disabled", "disabled");
            $("#send_state").html("正在投递中...");
        },
        success: function (data) {
           //do something 
        },
        error: function (xhr) {
            $("#btn_post_resume").html(xhr.responseText);
        },
        complete: function () {
            $("#btnSendResume").removeAttr("disabled");
            $("#send_state").text('');
        }
    });
在后台接受的方法中需要加上[frombody]特性

 public async Task<ActionResult> Send(long id, [FromBody]ResumeSendInfo sendInfo)
 { 
//other Code
}
　

 $("#HotJobs").load("/Offer/Ajax/HotJobsByCity?id="+'@(Model.AddressId)');
 

 ### source
 https://www.cnblogs.com/qulianqing/p/7162661.html