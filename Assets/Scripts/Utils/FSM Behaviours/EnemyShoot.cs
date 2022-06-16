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
    private GameObject m_projectile;

    [SerializeField]
    private GameObject m_fireVFX;

    [SerializeField]
    private GameObject m_chargeVFX;

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

    public Animator m_animator;

    public bool is_aiming;

    public void setPlayer(GameObject l_player)
    {
        m_player = l_player;
    }
    public bool GetIsLocked()
    {
        return m_alreadyLocked;
    }
    public void ResetShoot()
    {
        m_cadenceShoot = 0f;
        m_alreadyLocked = false;
        m_ray.material.color = Color.blue;
    }

    void Start()
    {
        m_ray.material.color = Color.blue;

        m_ray.enabled = false;

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
                m_animator.SetBool("Shoot", false);
                m_cadenceShoot = 0f;
            }
        }
    }

    private void LockOnPlayer()
    {
        if (!m_ray.enabled) 
        {
            if(m_animator.GetCurrentAnimatorStateInfo(0).IsName("Aiming") && m_animator.GetCurrentAnimatorStateInfo(0).normalizedTime >= 1f)
            {
                m_ray.enabled = true;
                is_aiming = true;

                if (m_chargeVFX != null)
                {
                    GameObject _smokeChargeVFX = Instantiate(m_chargeVFX, m_firePoint.transform.position, m_firePoint.transform.rotation) as GameObject;
                    _smokeChargeVFX.transform.parent = m_firePoint.transform;
                    Destroy(_smokeChargeVFX, 4);
                }
            }
        }
        else
        {
            m_cadenceShoot += Time.deltaTime;
        }

        bool isRight;
        Quaternion lookDirection = Quaternion.LookRotation(m_player.transform.position - transform.position);

        isRight = GetRotateDirection(transform.rotation, lookDirection);

        m_animator.SetBool("TurnR", isRight);

        float direction = Vector3.Angle(m_player.transform.position - transform.position, transform.forward);
        print(direction);
        if (direction <= 10f)
        {
            m_animator.SetLayerWeight(1, 0);
        }
        else
        {
            transform.rotation = Quaternion.Slerp(transform.rotation, lookDirection, 5f * Time.deltaTime);
            transform.eulerAngles = new Vector3(0f, transform.eulerAngles.y, transform.eulerAngles.z);
            m_animator.SetLayerWeight(1, 1);
        }

        Vector3 l_playerPos = m_player.transform.position;

        m_firePoint.forward = (l_playerPos - m_firePoint.position).normalized;

        if (m_cadenceShoot >= m_warningTime && !m_alreadyLocked)
        {
            m_ray.material.color = Color.red;
            m_alreadyLocked = true;
        }

        m_ray.SetPosition(0, m_firePoint.position);
        Ray l_Ray = new Ray(m_firePoint.position, l_playerPos - m_firePoint.position);
        if (Physics.Raycast(l_Ray, out RaycastHit l_RaycastHit, (l_playerPos - m_firePoint.position).magnitude, m_shootLayerMask.value))
        {
            m_ray.SetPosition(1, l_RaycastHit.point);
        }
        else
        {
            m_ray.SetPosition(1, l_playerPos);
        }
      

        if (m_cadenceShoot >= m_lockTime)
        {
            Vector3 l_finalDirection = l_playerPos - m_firePoint.position;
            Shoot(l_finalDirection);
            m_cadenceShoot = m_cooldownTime;
            m_ray.material.color = Color.blue;
            m_ray.enabled = false;
            m_alreadyLocked = false;
            m_canLock = false;
            is_aiming = false;
        }
    }
    private void Shoot(Vector3 dir)
    {
        GameObject l_projectile = m_projectilePool.GetNextElement();

        if(m_fireVFX != null)
        {
            GameObject _smokeFireVFX = Instantiate(m_fireVFX, m_firePoint.transform.position, m_firePoint.transform.rotation) as GameObject;
            Destroy(_smokeFireVFX, 2);
        }

        l_projectile.transform.position = m_firePoint.position;
        Rigidbody rb = l_projectile.GetComponent<Rigidbody>();
        rb.velocity = dir.normalized * m_projectileSpeed;
        l_projectile.transform.rotation = Quaternion.LookRotation(rb.velocity);
        l_projectile.transform.SetParent(null);
        l_projectile.SetActive(true);
        m_animator.SetBool("Shoot", true);
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
