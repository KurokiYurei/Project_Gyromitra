using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Explosive_Bullet : MonoBehaviour
{
    [SerializeField]
    private GameObject m_explosionCollider;

    [SerializeField]
    private float m_timeToExplode;

    private float m_timer;

    void Update()
    {
        if(m_timer >= m_timeToExplode)
        {
            Explosion(transform.position);
        }
        m_timer += Time.deltaTime;
    }

    private void OnCollisionEnter(Collision collision)
    {
        Explosion(collision.contacts[0].point);
    }

    private void Explosion(Vector3 pos)
    {
        m_timer = 0f;
        gameObject.SetActive(false);
        GameObject l_explosion = Instantiate(m_explosionCollider, pos, transform.rotation, null);
        l_explosion.SetActive(false);
        l_explosion.transform.position = pos;
        l_explosion.SetActive(true);
        l_explosion.GetComponent<Animation>().Play("Explosion");
    }
}
