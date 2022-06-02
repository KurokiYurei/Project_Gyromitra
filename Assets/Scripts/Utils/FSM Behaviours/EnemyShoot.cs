using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class EnemyShoot : MonoBehaviour
{
    [SerializeField]
    private float m_cadenceShoot;
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

    private Animator m_animator;

    void Start()
    {
        m_ray = gameObject.transform.Find("Firepoint").transform.GetComponent<LineRenderer>();

        m_ray.material.color = Color.blue;

        m_projectilePool = new PoolElements(1, transform, m_projectile);


    }

    void Update()
    {
        if (m_canLock)
        {
            LockOnPlayer();
        }
        else
        {
            m_cadenceShoot -= Time.deltaTime;
            if (m_cadenceShoot <= 0)
            {
                m_canLock = true;
                m_cadenceShoot = 0f;
            }
        }
    }

    private void LockOnPlayer()
    {
        if (!m_ray.enabled)
        {
            m_ray.enabled = true;
        }

        bool isRight;
        Quaternion lookDirection = Quaternion.LookRotation(m_player.transform.position - transform.position);

        isRight = GetRotateDirection(transform.rotation, lookDirection);
        
        transform.rotation = Quaternion.Slerp(transform.rotation, lookDirection, 10f * Time.deltaTime);
        transform.eulerAngles = new Vector3(0f, transform.eulerAngles.y, transform.eulerAngles.z);

        Vector3 l_playerPos = m_player.transform.position;

        m_firePoint.forward = (l_playerPos - m_firePoint.position).normalized;

        if (m_cadenceShoot >= m_warningTime && !m_alreadyLocked)
        {
            m_ray.material.color = Color.red;
            m_alreadyLocked = true;
        }

        Ray l_Ray = new Ray(m_firePoint.position, l_playerPos - m_firePoint.position);
        if (Physics.Raycast(l_Ray, out RaycastHit l_RaycastHit, (l_playerPos - m_firePoint.position).magnitude, m_shootLayerMask.value))
        {
            m_ray.SetPosition(0, m_firePoint.position);
            m_ray.SetPosition(1, l_playerPos);
        }

        m_ray.SetPosition(0, m_firePoint.position);
        m_ray.SetPosition(1, l_playerPos);

        if (m_cadenceShoot >= m_lockTime)
        {
            Vector3 l_finalDirection = l_playerPos - m_firePoint.position;
            Shoot(l_finalDirection);
            m_cadenceShoot = m_cooldownTime;
            m_ray.material.color = Color.blue;
            m_ray.enabled = false;
            m_alreadyLocked = false;
            m_canLock = false;
        }

        m_cadenceShoot += Time.deltaTime;
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
        m_animator.SetTrigger("Shoot");
    }

    public void setPlayer(GameObject l_player)
    {
        m_player = l_player;
    }
    bool GetRotateDirection(Quaternion from, Quaternion to)
    {
        float fromY = from.eulerAngles.y;
        float toY = to.eulerAngles.y;
        float clockWise = 0f;
        float counterClockWise = 0f;

        if (fromY <= toY)
        {
            clockWise = toY - fromY;
            counterClockWise = fromY + (360 - toY);
        }
        else
        {
            clockWise = (360 - fromY) + toY;
            counterClockWise = fromY - toY;
        }
        return (clockWise <= counterClockWise);
    }
}
