package com.ruoyi.common.utils;

import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;
import com.ruoyi.project.system.menu.domain.Menu;

/**
 * 权限数据处理
 * 
 * @author ruoyi
 */
public class TreeUtils
{
    /**
     * 根据父节点ID获取所有子节点
     * 
     * @param list 菜单列表
     * @param parentId 传入的父节点ID
     * @return 菜单列表
     */
    public static List<Menu> getChildPerms(List<Menu> list, int parentId)
    {
        List<Menu> returnList = new ArrayList<Menu>();
        if (list == null)
        {
            return returnList;
        }
        for (Iterator<Menu> iterator = list.iterator(); iterator.hasNext();)
        {
            Menu t = iterator.next();
            if (t == null || t.getParentId() == null)
            {
                continue;
            }
            if (t.getParentId() == parentId)
            {
                recursionFn(list, t);
                returnList.add(t);
            }
        }
        return returnList;
    }

    /**
     * 递归列表
     * 
     * @param list 菜单列表
     * @param t 节点
     */
    private static void recursionFn(List<Menu> list, Menu t)
    {
        if (t == null)
        {
            return;
        }
        List<Menu> childList = getChildList(list, t);
        t.setChildren(childList);
        for (Menu tChild : childList)
        {
            if (hasChild(list, tChild))
            {
                recursionFn(list, tChild);
            }
        }
    }

    /**
     * 得到子节点列表
     */
    private static List<Menu> getChildList(List<Menu> list, Menu t)
    {
        List<Menu> tlist = new ArrayList<Menu>();
        if (list == null || t == null || t.getMenuId() == null)
        {
            return tlist;
        }
        Iterator<Menu> it = list.iterator();
        while (it.hasNext())
        {
            Menu n = it.next();
            if (n == null || n.getParentId() == null || n.getMenuId() == null)
            {
                continue;
            }
            if (n.getParentId().longValue() == t.getMenuId().longValue())
            {
                tlist.add(n);
            }
        }
        return tlist;
    }

    List<Menu> returnList = new ArrayList<Menu>();

    /**
     * 根据父节点的ID获取所有子节点
     * 
     * @param list 菜单列表
     * @param typeId 父节点ID
     * @param prefix 子节点前缀
     */
    public List<Menu> getChildPerms(List<Menu> list, int typeId, String prefix)
    {
        if (list == null)
        {
            return null;
        }
        for (Iterator<Menu> iterator = list.iterator(); iterator.hasNext();)
        {
            Menu node = iterator.next();
            if (node == null || node.getParentId() == null)
            {
                continue;
            }
            if (node.getParentId() == typeId)
            {
                recursionFn(list, node, prefix);
            }
        }
        return returnList;
    }

    private void recursionFn(List<Menu> list, Menu node, String p)
    {
        if (node == null)
        {
            return;
        }
        List<Menu> childList = getChildList(list, node);
        if (hasChild(list, node))
        {
            returnList.add(node);
            Iterator<Menu> it = childList.iterator();
            while (it.hasNext())
            {
                Menu n = it.next();
                if (n == null)
                {
                    continue;
                }
                n.setMenuName(p + n.getMenuName());
                recursionFn(list, n, p + p);
            }
        }
        else
        {
            returnList.add(node);
        }
    }

    /**
     * 判断是否有子节点
     */
    private static boolean hasChild(List<Menu> list, Menu t)
    {
        return getChildList(list, t).size() > 0;
    }
}
