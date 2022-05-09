using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class EnemyShoot : MonoBehaviour
{
    private float m_timer;
    private bool m_alreadyLocked;
    private bool m_canLock;

    private GameObject m_player;

    [SerializeField]
    private float m_locationRadius;

    [SerializeField]
    private GameObject m_projectile;

    [SerializeField]
    private float m_projectileSpeed = 100f;

    [SerializeField]
    private float m_cooldownTime;

    [SerializeField]
    private float m_lockTime;

    [SerializeField]
    private float m_warningTime;

    [SerializeField]
    private Transform m_firePoint;

    [SerializeField]
    private LineRenderer m_ray;

    [SerializeField]
    private LayerMask m_shootLayerMask;

    static PoolElements m_projectilePool;

    // Start is called before the first frame update
    void Start()
    {
        m_ray.material.color = Color.blue;

        m_projectilePool = new PoolElements(3, transform, m_projectile);
    }

    // Update is called once per frame
    void Update()
    {
        if (m_canLock)
        {
            LockOnPlayer();
        }
        else
        {
            m_ray.enabled = false;
            m_timer -= Time.deltaTime;
            if (m_timer <= 0)
            {
                m_canLock = true;
                m_timer = 0f;
            }
        }
    }

    private void LockOnPlayer()
    {
        if (m_player != null)
        {
            m_ray.enabled = true;

            transform.LookAt(m_player.transform);
            transform.eulerAngles = new Vector3(0f, transform.eulerAngles.y, transform.eulerAngles.z);

            Vector3 l_playerPos = m_player.transform.position;

            m_firePoint.forward = (l_playerPos - m_firePoint.position).normalized;

            if (m_timer >= m_warningTime && !m_alreadyLocked)
            {
                m_ray.material.color = Color.red;
                m_alreadyLocked = true;
            }

            Ray l_Ray = new Ray(m_firePoint.position, l_playerPos - m_firePoint.position);
            if (Physics.Raycast(l_Ray, out RaycastHit l_RaycastHit, (l_playerPos - m_firePoint.position).magnitude, m_shootLayerMask.value))
            {
                m_ray.SetPosition(0, m_firePoint.position);
                m_ray.SetPosition(1,l_playerPos);
            }

            if (m_timer >= m_lockTime)
            {
                Vector3 l_finalDirection = l_playerPos - m_firePoint.position;
                Shoot(l_finalDirection);
                m_timer = m_cooldownTime;
                m_ray.material.color = Color.blue;
                m_alreadyLocked = false;
                m_canLock = false;
            }
            m_timer += Time.deltaTime;
        }
        else
        {
            m_ray.enabled = false;
        }
    }

    private void Shoot(Vector3 dir)
    {
        GameObject l_projectile = m_projectilePool.GetNextElement();

        l_projectile.transform.position = m_firePoint.position;
        Rigidbody rb = l_projectile.GetComponent<Rigidbody>();
        rb.velocity = dir.normalized * m_projectileSpeed;
        l_projectile.transform.rotation = Quaternion.LookRotation(rb.velocity);
        l_projectile.transform.SetParent(null);
        l_projectile.SetActive(true);
    }

    public void setPlayer(GameObject l_player)
    {
        m_player = l_player;
    }

}
