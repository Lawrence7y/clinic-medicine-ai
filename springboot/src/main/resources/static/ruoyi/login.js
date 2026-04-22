var rememberStoreKey = "ruoyi_admin_login_remember";
var usernameStoreKey = "ruoyi_admin_login_username";
var passwordStoreKey = "ruoyi_admin_login_password";

$(function() {
    validateKickout();
    validateRule();
    loadRememberedAccount();
    $('.imgcode').click(function() {
        var url = ctx + "captcha/captchaImage?type=" + captchaType + "&s=" + Math.random();
        $(".imgcode").attr("src", url);
    });
});

function isPhoneOrAdmin(username) {
    return username === "admin" || /^1\d{10}$/.test(username);
}

function login() {
    var username = $.common.trim($("input[name='username']").val());
    var password = $.common.trim($("input[name='password']").val());
    var validateCode = $("input[name='validateCode']").val();
    var rememberMe = $("input[name='rememberme']").is(':checked');

    if (!isPhoneOrAdmin(username)) {
        $.modal.msg("仅支持手机号登录，管理员请使用 admin 账号");
        return false;
    }

    if ($.common.isEmpty(validateCode) && captchaEnabled) {
        $.modal.msg("请输入验证码");
        return false;
    }

    $.ajax({
        type: "post",
        url: ctx + "login",
        data: {
            "username": username,
            "password": password,
            "validateCode": validateCode,
            "rememberMe": rememberMe
        },
        beforeSend: function() {
            $.modal.loading($("#btnSubmit").data("loading"));
        },
        success: function(r) {
            if (r.code == web_status.SUCCESS) {
                saveRememberedAccount(rememberMe, username, password);
                location.href = ctx + 'index';
            } else {
                $('.imgcode').click();
                $(".code").val("");
                $.modal.msg(r.msg);
            }
            $.modal.closeLoading();
        }
    });
}

function validateRule() {
    var icon = "<i class='fa fa-times-circle'></i> ";
    $("#signupForm").validate({
        rules: {
            username: {
                required: true
            },
            password: {
                required: true
            }
        },
        messages: {
            username: {
                required: icon + "请输入手机号或 admin"
            },
            password: {
                required: icon + "请输入密码"
            }
        },
        submitHandler: function(form) {
            login();
        }
    });
}

function validateKickout() {
    if (getParam("kickout") == 1) {
        layer.alert("<font color='red'>您已在别处登录，请修改密码或重新登录</font>", {
            icon: 0,
            title: "系统提示"
        }, function(index) {
            layer.close(index);
            if (top != self) {
                top.location = self.location;
            } else {
                var url = location.search;
                if (url) {
                    var oldUrl = window.location.href;
                    var newUrl = oldUrl.substring(0, oldUrl.indexOf('?'));
                    self.location = newUrl;
                }
            }
        });
    }
}

function getParam(paramName) {
    var reg = new RegExp("(^|&)" + paramName + "=([^&]*)(&|$)");
    var r = window.location.search.substr(1).match(reg);
    if (r != null) return decodeURI(r[2]);
    return null;
}

function loadRememberedAccount() {
    var rememberEl = $("input[name='rememberme']");
    if (!rememberEl.length) {
        return;
    }
    var remembered = localStorage.getItem(rememberStoreKey) === "true";
    if (!remembered) {
        return;
    }
    $("input[name='username']").val(localStorage.getItem(usernameStoreKey) || "");
    $("input[name='password']").val(localStorage.getItem(passwordStoreKey) || "");
    rememberEl.prop('checked', true);
}

function saveRememberedAccount(rememberMe, username, password) {
    if (rememberMe) {
        localStorage.setItem(rememberStoreKey, "true");
        localStorage.setItem(usernameStoreKey, username);
        localStorage.setItem(passwordStoreKey, password);
        return;
    }
    localStorage.removeItem(rememberStoreKey);
    localStorage.removeItem(usernameStoreKey);
    localStorage.removeItem(passwordStoreKey);
}
