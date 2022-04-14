using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Mushroom : MonoBehaviour
{
    [SerializeField]
    private Mushroom m_mushroomPrefab;

    private string m_mushroomTag;

    //private PoolElements m_mushroomPool;
    //public GameObject m_mushroomPrefabTest;

    private Mushroom m_currentMushroom;

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

    public void SpawnMushroom(GameObject startPosition)
    {
        //print(this.transform);
        //print(m_mushroomPool);
        //print(m_mushroomPrefab);

        //GameObject l_mushroom = m_mushroomPool.GetNextElement();
        //l_mushroom.SetActive(true);
        //l_mushroom.transform.SetParent(null);
        //l_mushroom.transform.position = startPosition.transform.position;

        m_currentMushroom = Instantiate(m_mushroomPrefab);
        m_currentMushroom.transform.position = startPosition.transform.position;

        //m_currentMushroom.transform.position = startPosition.transform.position;
        //Instantiate(m_mushroom, gameObject.transform.position, Quaternion.identity);
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
