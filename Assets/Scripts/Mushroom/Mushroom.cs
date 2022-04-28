using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Mushroom : MonoBehaviour
{
    private string m_mushroomTag;
    public float m_timeToDestroy = 5.0f;
    public float m_currentTime;

    void Start()
    {
        //m_mushroomPool = new PoolElements(m_maxMushrooms, null, m_mushroomPrefabTest);
        SetMushroomTag(gameObject.tag);
    }

    // Update is called once per frame
    void Update()
    {
        if (m_currentTime >= m_timeToDestroy)
        {
            print("Destroy mushroom");
            DestroyMushroom();
        }
        m_currentTime += Time.deltaTime;
    }

    public void DestroyMushroom()
    {
        //print("Destroy mushroom");
        //Destroy(this.gameObject, m_timeToDestroy);

        gameObject.SetActive(false);
        CharacterControllerScript.GetPool().m_ActiveElementsList.Remove(gameObject);
        CharacterControllerScript.GetPool().m_CurrentAmount -= 1;

        m_currentTime = 0.0f;
    }
    public void SetMushroomTag(string mushroomTag)
    {
        m_mushroomTag = mushroomTag;
    }

    public string GetMushroomTag()
    {
        return m_mushroomTag;
    }

    //private void OnTriggerEnter(Collider other)
    //{
    //    if (other.tag == "Enemy")
    //    {
    //        print("Enemy collision");
    //    }
    //}
}
