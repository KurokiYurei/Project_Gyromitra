using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PoolElements
{
    public List<GameObject> m_ElementsList;
    private int m_CurrentElementId;

    /// <summary>
    /// create the list of elements
    /// </summary>
    /// <param name="count"></param>
    /// <param name="parent"></param>
    /// <param name="prefab"></param>
    public PoolElements(int count, Transform parent, GameObject prefab)
    {
        m_ElementsList = new List<GameObject>();
        m_CurrentElementId = 0;

        for (int i = 0; i < count; i++)
        {
            GameObject l_Element = GameObject.Instantiate(prefab, parent);
            l_Element.SetActive(false);
            m_ElementsList.Add(l_Element);
        }
    }

    /// <summary>
    /// get the next element of the list
    /// </summary>
    /// <returns></returns>
    public GameObject GetNextElement()
    {
        GameObject l_Element = m_ElementsList[m_CurrentElementId];
        m_CurrentElementId++;

        if (m_CurrentElementId >= m_ElementsList.Count)
        {
            m_CurrentElementId = 0;
        }

        return l_Element;
    }
}
