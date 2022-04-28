using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Explosive_Bullet : MonoBehaviour
{
    //[SerializeField]
    //private float m_damage = 15f;

    [SerializeField]
    private GameObject m_explosionCollider;

    [SerializeField]
    private Rigidbody m_rigidBody;

    [SerializeField]
    private float m_explosionRadius;

    [SerializeField]
    private float m_explosionForce;

    [SerializeField]
    private float m_locationRadius;

    private string m_playerTag;

    private bool m_hit;





    void Start()
    {
        m_playerTag = UtilsGyromitra.SearchForTag("Player");
    }

    // Update is called once per frame
    void Update()
    {
        //transform.rotation = Quaternion.LookRotation(m_rigidBody.velocity);
    }

    private void LocatePlayerPositon()
    {
        GameObject l_player = UtilsGyromitra.FindInstanceWithinRadius(this.gameObject, m_playerTag, m_locationRadius);
    }

    private void OnTriggerEnter(Collider other)
    {
        //print("Entro al collider");
        //m_rigidBody.AddExplosionForce(m_explosionForce, transform.position, m_explosionRadius);


    }

    private void OnCollisionEnter(Collision collision)
    {
        print("Entro al collider");

        if (collision.collider.CompareTag(m_playerTag))
        {
            //GameObject l_player = UtilsGyromitra.FindInstanceWithinRadius(this.gameObject, m_playerTag, m_locationRadius);

            //if (l_player != null)
            //{

            //}

            GameObject l_explosion = Instantiate(m_explosionCollider, transform);


            l_explosion.transform.position = collision.contacts[0].point;
            l_explosion.transform.SetParent(null);
            l_explosion.SetActive(true);
        }
    }
}
