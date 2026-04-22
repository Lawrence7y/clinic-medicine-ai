package com.ruoyi.common.exception.user;

/**
 * 角色不允许登录后台异常
 * 
 * @author ruoyi
 */
public class RoleNotAllowedException extends UserException
{
    private static final long serialVersionUID = 1L;

    public RoleNotAllowedException()
    {
        super("role.not.allowed", null);
    }
}
