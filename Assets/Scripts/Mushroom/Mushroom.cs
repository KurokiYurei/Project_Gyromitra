using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Mushroom : MonoBehaviour
{
    [SerializeField]
    private Mushroom m_mushroomPrefab;
    private string m_mushroomTag;

    private Mushroom m_currentMushroom;

    void Start()
    {

    }

    // Update is called once per frame
    void Update()
    {

    }

    public void SpawnMushroom(GameObject startPosition)
    {
        m_currentMushroom = Instantiate(m_mushroomPrefab);
        m_currentMushroom.transform.position = startPosition.transform.position;

        //m_currentMushroom.transform.position = startPosition.transform.position;
        //Instantiate(m_mushroom, gameObject.transform.position, Quaternion.identity);
    }
    public void SetEnemyTag(string mushroomTag)
    {
        m_mushroomTag = mushroomTag;
    }

    public string GetEnemyTag()
    {
        return m_mushroomTag;
    }


}
