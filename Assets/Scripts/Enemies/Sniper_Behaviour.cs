using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.AI;

public class Sniper_Behaviour : MonoBehaviour
{
    [SerializeField]
    private float m_fireRadius;

    [SerializeField]
    private float m_cooldownTime;

    [SerializeField]
    private Transform m_firePoint;

    [SerializeField]
    private LayerMask m_shootLayerMask;

    [SerializeField]
    private float m_sniperDamage;

    [SerializeField]
    private NavMeshAgent m_navMeshAgent;

    [SerializeField]
    private float m_radiusNearTarget;

    [SerializeField]
    private int m_minRad = 10;
    [SerializeField]
    private int m_maxRad = 100;
    
    private Vector3 m_targetPos;

    private string m_playerTag;
    private float m_timer;


    void Start()
    {
        m_playerTag = UtilsGyromitra.SearchForTag("Player");
        m_targetPos = RandomNavmeshLocation(UtilsGyromitra.RandomNumber(m_minRad, m_maxRad)); 
        m_navMeshAgent.SetDestination(m_targetPos);
        m_radiusNearTarget = 2f;
    }

    void Update()
    {
        // ShootSniper();

        if (Vector3.Distance(transform.position, m_targetPos) <= m_radiusNearTarget)
        {
            m_targetPos = RandomNavmeshLocation(UtilsGyromitra.RandomNumber(m_minRad, m_maxRad));
            print(m_targetPos);
            m_navMeshAgent.SetDestination(m_targetPos);
        }

    }

    private void ShootSniper()
    {
        GameObject l_player = UtilsGyromitra.FindInstanceWithinRadius(this.gameObject, m_playerTag, m_fireRadius);

        if (l_player != null)
        {
            Vector3 l_playerPos = l_player.transform.position;
            Vector3 l_enemyPos = gameObject.transform.position;

            Vector3 l_direction = l_playerPos - l_enemyPos;

            m_timer += Time.deltaTime;

            if (m_timer >= m_cooldownTime)
            {
                Ray l_ray = new Ray(m_firePoint.position, l_direction);
                RaycastHit l_raycastHit;

                if (Physics.Raycast(l_ray, out l_raycastHit, m_fireRadius, m_shootLayerMask))
                {
                    l_player.GetComponent<CharacterHP>().Damage(m_sniperDamage);

                    print(l_player.tag);
                    Debug.DrawLine(m_firePoint.position, l_raycastHit.point, Color.red);

                    //yield WaitForSeconds(5);
                    m_timer = 0;
                }


            }
        }

    }

    public Vector3 RandomNavmeshLocation(float l_radius)
    {
        Vector3 l_randomDirection = Random.insideUnitSphere * l_radius;
        l_randomDirection += transform.position;
        NavMeshHit l_hit;
        Vector3 l_finalPosition = Vector3.zero;

        if (NavMesh.SamplePosition(l_randomDirection, out l_hit, l_radius, 1))
        {
            l_finalPosition = l_hit.position;
        }

        return l_finalPosition;
    }
}
