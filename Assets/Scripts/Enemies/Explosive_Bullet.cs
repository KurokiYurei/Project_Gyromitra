using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Explosive_Bullet : MonoBehaviour
{
    [SerializeField]
    private GameObject m_explosionCollider;

    [SerializeField]
    private float m_timeToExplode;

    [SerializeField]
    private Transform m_rayPoint;

    [SerializeField]
    private float m_distanceHit;

    [SerializeField]
    private Rigidbody m_rigidBody;

    private float m_timer;

    void Update()
    {
        transform.rotation = Quaternion.LookRotation(m_rigidBody.velocity);

        Ray l_ray = new Ray(m_rayPoint.position, m_rayPoint.forward);

        if (Physics.Raycast(l_ray, out RaycastHit l_hit, m_distanceHit))
        {
            Explosion(l_hit.point);
        }

        if (m_timer >= m_timeToExplode)
        {
            Explosion(l_hit.point);
        }
        m_timer += Time.deltaTime;
    }

    private void Explosion(Vector3 pos)
    {
        m_timer = 0f;
        gameObject.SetActive(false);
        GameObject l_explosion = Instantiate(m_explosionCollider, pos, transform.rotation, null);
        l_explosion.SetActive(false);
        l_explosion.transform.position = pos;
        l_explosion.SetActive(true);
        //l_explosion.GetComponent<Animation>().Play("Explosion");
    }
}
