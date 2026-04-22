package com.ruoyi.project.clinic.common;

import com.ruoyi.common.utils.StringUtils;
import com.ruoyi.framework.web.domain.AjaxResult;
import org.apache.shiro.authz.AuthorizationException;
import org.apache.shiro.authz.UnauthenticatedException;
import org.springframework.http.converter.HttpMessageNotReadableException;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.MissingServletRequestParameterException;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;
import org.springframework.web.method.annotation.MethodArgumentTypeMismatchException;

@RestControllerAdvice(basePackages = "com.ruoyi.project.clinic")
public class ClinicApiExceptionHandler
{
    @ExceptionHandler(UnauthenticatedException.class)
    public AjaxResult handleUnauthenticated(UnauthenticatedException ex)
    {
        AjaxResult result = AjaxResult.error(ClinicApiMessages.MSG_NEED_LOGIN);
        result.put(AjaxResult.CODE_TAG, 401);
        return result;
    }

    @ExceptionHandler(AuthorizationException.class)
    public AjaxResult handleForbidden(AuthorizationException ex)
    {
        AjaxResult result = AjaxResult.error(ClinicApiMessages.MSG_NO_PERMISSION);
        result.put(AjaxResult.CODE_TAG, 403);
        return result;
    }

    @ExceptionHandler(IllegalArgumentException.class)
    public AjaxResult handleIllegalArg(IllegalArgumentException ex)
    {
        String message = StringUtils.trim(ex.getMessage());
        return AjaxResult.error(StringUtils.isNotEmpty(message) ? message : ClinicApiMessages.MSG_PARAM_INVALID);
    }

    @ExceptionHandler({
        HttpMessageNotReadableException.class,
        MethodArgumentTypeMismatchException.class,
        MissingServletRequestParameterException.class,
        MethodArgumentNotValidException.class,
        NumberFormatException.class
    })
    public AjaxResult handleBadRequest(Exception ex)
    {
        return AjaxResult.error(ClinicApiMessages.MSG_PARAM_INVALID);
    }

    @ExceptionHandler(Exception.class)
    public AjaxResult handleOthers(Exception ex)
    {
        return AjaxResult.error(ClinicApiMessages.MSG_SYSTEM_BUSY);
    }
}
