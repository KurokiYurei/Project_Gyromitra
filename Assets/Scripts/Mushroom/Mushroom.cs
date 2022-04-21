using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Mushroom : MonoBehaviour
{
    private string m_mushroomTag;
    public float m_timeToDestroy = 5.0f;
    public int m_maxMushrooms = 5;
    //public float m_currentTime;

    void Start()
    {
        //m_mushroomPool = new PoolElements(m_maxMushrooms, null, m_mushroomPrefabTest);
        SetMushroomTag(gameObject.tag);
    }

    // Update is called once per frame
    void Update()
    {
        //if (m_currentTime >= m_timeToDestroy)
        //{
        //    print("Destroy mushroom");
        //    DestroyMushroom();
        //}
        DestroyMushroom();

        //m_currentTime += Time.deltaTime;
    }

    public void DestroyMushroom()
    {
        //print("Destroy mushroom");
        Destroy(this.gameObject, m_timeToDestroy);

        //gameObject.SetActive(false);
        //m_currentTime = 0.0f;
    }
    public void SetMushroomTag(string mushroomTag)
    {
        m_mushroomTag = mushroomTag;
    }

    public string GetMushroomTag()
    {
        return m_mushroomTag;
    }
}
