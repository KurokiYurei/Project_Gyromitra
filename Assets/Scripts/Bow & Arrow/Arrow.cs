using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Arrow : MonoBehaviour
{

    [SerializeField]
    private float m_damage = 15f;

    [SerializeField]
    private Rigidbody m_rigidBody;

    [SerializeField]
    private string m_enemyTag;

    private bool m_Hit;

    private string m_mushroomSpawnable;

    private void Start()
    {
        m_mushroomSpawnable = UtilsGyromitra.SearchForTag("MushroomSpawnable");
    }

    private void Update()
    {
        transform.rotation = Quaternion.LookRotation(m_rigidBody.velocity);
    }

    private void OnTriggerEnter(Collider other)
    {
        if (m_Hit) return;
        m_Hit = true;

        if (other.CompareTag(m_enemyTag))
        {
            // fer mal al enemic

            IDamagable l_damageComponent = other.transform.GetComponent<IDamagable>();

            if (l_damageComponent != null)
            {
                l_damageComponent.Damage(m_damage);
            }

        }
  
    }

    private void OnCollisionEnter(Collision collision)
    {
        if (collision.transform.CompareTag(m_mushroomSpawnable) && collision.contacts[0].normal.y >= -0.01f)
        {
            Debug.DrawRay(collision.contacts[0].point, collision.contacts[0].normal, Color.red, 5f);
            if (collision.contacts[0].normal.y < 0.3f) //WALL MUSHROOM
            {
                GameObject l_mushroom = CharacterControllerScript.GetMushroomPool().GetNextElement(false);
                l_mushroom.GetComponent<Mushroom>().SetCurrentTime(0f);
                l_mushroom.transform.position = collision.contacts[0].point;
                l_mushroom.transform.forward = collision.contacts[0].normal;
                l_mushroom.transform.SetParent(null);
                l_mushroom.SetActive(true);
            }
            else //NORMAL MUSHROOM
            {
                GameObject l_mushroom = CharacterControllerScript.GetMushroomPool().GetNextElement(true);
                l_mushroom.GetComponent<Mushroom>().SetCurrentTime(0f);
                l_mushroom.transform.position = collision.contacts[0].point;
                l_mushroom.transform.SetParent(null);
                l_mushroom.SetActive(true);
            }
        }
        if (collision.collider.tag == "Enemy")
        {
            collision.gameObject.GetComponent<Hit_Collider>().Hit();
        }
        gameObject.SetActive(false);
    }
}
