using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class DoublePoolElements
{
    public List<GameObject> m_Element1List;
    public List<GameObject> m_Element2List;
    public List<GameObject> m_ActiveElementsList;
    private int m_CurrentElementId1;
    private int m_CurrentElementId2;
    private int m_MaxAmount;
    public int m_CurrentAmount;

    /// <summary>
    /// Create the pool for two types of elements in one list
    /// </summary>
    /// <param name="count"></param>
    /// <param name="parent"></param>
    /// <param name="prefab1"></param>
    /// <param name="prefab2"></param>
    public DoublePoolElements(int count, Transform parent, GameObject prefab1, GameObject prefab2)
    {
        m_Element1List = new List<GameObject>();
        m_Element2List = new List<GameObject>();
        m_ActiveElementsList = new List<GameObject>();
        m_CurrentElementId1 = 0;
        m_CurrentElementId2 = 0;
        m_MaxAmount = count;

        for (int i = 0; i < count; i++)
        {
            GameObject l_Element1 = GameObject.Instantiate(prefab1, parent);
            l_Element1.SetActive(false);
            m_Element1List.Add(l_Element1);
        }
        for (int i = 0; i < count; i++)
        {
            GameObject l_Element2 = GameObject.Instantiate(prefab2, parent);
            l_Element2.SetActive(false);
            m_Element2List.Add(l_Element2);
        }
    }

    /// <summary>
    /// get the next element of a pool
    /// </summary>
    /// <param name="firstElement"></param>
    /// <returns></returns>
    public GameObject GetNextElement(bool firstElement)
    {
        if(m_CurrentAmount >= m_MaxAmount)
        {
            m_ActiveElementsList[0].GetComponent<Mushroom>().SmokeVFX();
            m_ActiveElementsList[0].SetActive(false);
            m_ActiveElementsList.RemoveAt(0);

            //for (int i = 0; i < m_ActiveElementsList.Count; i++)
            //{
            //    if (m_ActiveElementsList[i].activeSelf)
            //    {
            //        m_ActiveElementsList[i].SetActive(false);
            //        m_ActiveElementsList.RemoveAt(0);
            //        break;
            //    }
            //}
        }
            
        if (firstElement)
        {
            GameObject l_Element = m_Element1List[m_CurrentElementId1];
            m_ActiveElementsList.Add(l_Element);
            m_CurrentElementId1 += 1;

            if (m_CurrentElementId1 >= m_Element1List.Count)
            {
                m_CurrentElementId1 = 0;
            }

            return l_Element;
        }
        else
        {
            GameObject l_Element = m_Element2List[m_CurrentElementId2];
            m_ActiveElementsList.Add(l_Element);
            m_CurrentElementId2 += 1;

            if (m_CurrentElementId2 >= m_Element2List.Count)
            {
                m_CurrentElementId2 = 0;
            }

            return l_Element;
        }
    }
}
