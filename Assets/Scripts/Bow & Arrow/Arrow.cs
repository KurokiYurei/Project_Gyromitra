using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Arrow : MonoBehaviour
{
    // damage that the arrow does if we implement an Health Script
    // private float m_damage;

    [SerializeField]
    private float m_damage = 15f;

    [SerializeField]
    private Rigidbody m_rigidBody;

    private string m_enemyTag;

    private bool m_Hit;

    public string m_mushroomSpawnable;

    private void Awake()
    {
        //m_mushroomSpawnable = m_mushroomPrefab.GetTag();
    }

    private void Update()
    {
        transform.rotation = Quaternion.LookRotation(m_rigidBody.velocity);
        //m_mushroom.GetComponent<Mushroom>();
    }

    public void SetEnemyTag(string enemyTag)
    {
        m_enemyTag = enemyTag;
    }

    /*
    public void Fly(Vector3 force)
    {
        m_rigidBody.isKinematic = false;
        m_rigidBody.AddForce(force, ForceMode.Impulse);
        m_rigidBody.AddTorque(m_torque * transform.right);
        transform.SetParent(null);
    }*/

    private void OnTriggerEnter(Collider other)
    {
        if (m_Hit) return;
        m_Hit = true;

        print(other.tag);

        if (other.CompareTag(m_enemyTag))
        {
            // fer mal al enemic

            IDamagable l_damageComponent = other.transform.GetComponent<IDamagable>();

            if (l_damageComponent != null)
            {
                l_damageComponent.Damage(m_damage);
            }

        }

        // si es vol que es quedi la fletxa encrustrada en l'objecte
        //m_rigidBody.velocity = Vector3.zero;
        //m_rigidBody.angularVelocity = Vector3.zero;
        //m_rigidBody.isKinematic = true;
        //transform.SetParent(other.transform);    
    }

    private void OnCollisionEnter(Collision collision)
    {

        // print(collision.transform.tag);

        if (collision.transform.CompareTag(m_mushroomSpawnable) && collision.contacts[0].normal.y >= -0.01f)
        {
            Debug.DrawRay(collision.contacts[0].point, collision.contacts[0].normal, Color.red, 5f);
            if (collision.contacts[0].normal.y < 0.3f) //WALL MUSHROOM
            {
                GameObject l_mushroom = CharacterControllerScript.GetPool().GetNextElement(false);
                l_mushroom.GetComponent<Mushroom>().m_currentTime = 0f;
                l_mushroom.transform.position = collision.contacts[0].point;
                l_mushroom.transform.forward = collision.contacts[0].normal;
                l_mushroom.transform.SetParent(null);
                l_mushroom.SetActive(true);
            }
            else //NORMAL MUSHROOM
            {
                GameObject l_mushroom = CharacterControllerScript.GetPool().GetNextElement(true);
                l_mushroom.GetComponent<Mushroom>().m_currentTime = 0f;
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
