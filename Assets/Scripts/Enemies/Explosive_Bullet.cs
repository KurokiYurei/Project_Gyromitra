using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Explosive_Bullet : MonoBehaviour
{
    //[SerializeField]
    //private float m_damage = 15f;

    [SerializeField]
    private GameObject m_explosionCollider;

    private string m_playerTag;

    private bool m_hit;

    [SerializeField]
    private float m_timeToExplode;

    private float m_timer;

    void Start()
    {
        m_playerTag = UtilsGyromitra.SearchForTag("Player");
    }

    // Update is called once per frame
    void Update()
    {
        if(m_timer >= m_timeToExplode)
        {
            Explosion(transform.position);
            gameObject.SetActive(false);
        }
        m_timer += Time.deltaTime;
    }

    private void OnCollisionEnter(Collision collision)
    {
        print("Entro al collider");

        //if (collision.collider.CompareTag(m_playerTag))
        //{
        //    Explosion(collision.contacts[0].point);
        //}
        //else
        //{

        //}

        Explosion(collision.contacts[0].point);

        gameObject.SetActive(false);
    }

    private void Explosion(Vector3 pos)
    {
        GameObject l_explosion = Instantiate(m_explosionCollider, pos, transform.rotation, null);
        l_explosion.SetActive(false);
        l_explosion.transform.position = pos;
        l_explosion.SetActive(true);
        l_explosion.GetComponent<Animation>().Play("Explosion");
    }
}
