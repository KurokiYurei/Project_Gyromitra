using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Arrow : MonoBehaviour
{
    [SerializeField]
    private Rigidbody m_rigidBody;

    private string m_enemyTag;

    private string m_mushroomSpawnableTag;

    private string m_mobilePlatformTag;

    private void Start()
    {
        m_mushroomSpawnableTag = UtilsGyromitra.SearchForTag("MushroomSpawnable");
        m_mobilePlatformTag = UtilsGyromitra.SearchForTag("MobilePlatform");
        m_enemyTag = UtilsGyromitra.SearchForTag("Enemy");
    }

    private void Update()
    {
        transform.rotation = Quaternion.LookRotation(m_rigidBody.velocity);
    }

    private void OnCollisionEnter(Collision collision)
    {
        GameObject l_mushroom = null;

        if ((collision.transform.CompareTag(m_mushroomSpawnableTag) || collision.transform.CompareTag(m_mobilePlatformTag)) && collision.contacts[0].normal.y >= -0.01f)
        {
            Debug.DrawRay(collision.contacts[0].point, collision.contacts[0].normal, Color.red, 5f);
            if (collision.contacts[0].normal.y < 0.3f) //WALL MUSHROOM
            {
                l_mushroom = CharacterControllerScript.GetMushroomPool().GetNextElement(false);
                l_mushroom.GetComponent<Mushroom>().SetCurrentTime(0f);
                l_mushroom.transform.position = collision.contacts[0].point;
                l_mushroom.transform.forward = collision.contacts[0].normal;

                print(collision.transform.CompareTag(m_mobilePlatformTag));

                if (collision.transform.CompareTag(m_mobilePlatformTag))
                {
                    l_mushroom.transform.SetParent(collision.transform);
                }
                else
                {
                    l_mushroom.transform.SetParent(null);
                }

                l_mushroom.SetActive(true);
            }
            else //NORMAL MUSHROOM
            {
                l_mushroom = CharacterControllerScript.GetMushroomPool().GetNextElement(true);
                l_mushroom.GetComponent<Mushroom>().SetCurrentTime(0f);
                l_mushroom.transform.position = collision.contacts[0].point;

                if (collision.transform.CompareTag(UtilsGyromitra.SearchForTag(m_mobilePlatformTag)))
                {
                    l_mushroom.transform.SetParent(collision.transform);
                }
                else
                {
                    l_mushroom.transform.SetParent(null);
                }

                l_mushroom.SetActive(true);
            }
        }

        if (collision.transform.CompareTag(m_enemyTag))
        {
            collision.collider.GetComponent<Hit_Collider>().Hit();
        }

        gameObject.SetActive(false);
    }
}
