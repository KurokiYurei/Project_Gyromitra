using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.AI;

public class Sniper_Behaviour : MonoBehaviour
{
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

    [SerializeField]
    private NavMeshAgent m_navMeshAgent;

    public List<Transform> m_patrolWaypoints;
    int m_currentWaypointId = 0;

    [SerializeField]
    private float m_radiusNearTarget;

    [SerializeField]
    private int m_minRad = 10;
    [SerializeField]
    private int m_maxRad = 100;



    private Vector3 m_targetPos;
    Vector3 m_finalPlayerPos;

    private string m_playerTag;
    private float m_timer;
    private bool m_alreadyLocked;
    private bool m_canLock;
    NavMeshAgent m_NavMeshAgent;
    private string m_mushroomTag;
    private Vector3 m_bounceDirection;
    private float m_bouncePower;
    private float m_bounceTimer;
    private bool m_bouncing;


    void Start()
    {
        m_playerTag = UtilsGyromitra.SearchForTag("Player");
        m_mushroomTag = UtilsGyromitra.SearchForTag("Mushroom");
        //m_targetPos = RandomNavmeshLocation(UtilsGyromitra.RandomNumber(m_minRad, m_maxRad));
        //m_navMeshAgent.SetDestination(m_targetPos);
        m_radiusNearTarget = 2f;
        m_ray.material.color = Color.blue;

        m_NavMeshAgent = gameObject.GetComponent<NavMeshAgent>();

        MoveToNextPatrolPosition();
    }

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

        if (!m_navMeshAgent.hasPath && m_navMeshAgent.pathStatus == NavMeshPathStatus.PathComplete)
            MoveToNextPatrolPosition();

        //if (Vector3.Distance(transform.position, m_targetPos) <= m_radiusNearTarget)
        //{
        //    m_targetPos = RandomNavmeshLocation(UtilsGyromitra.RandomNumber(m_minRad, m_maxRad));
        //    print(m_targetPos);
        //    m_navMeshAgent.SetDestination(m_targetPos);
        //}
    }
    //Movement method

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

    void MoveToNextPatrolPosition()
    {
        m_navMeshAgent.destination = m_patrolWaypoints[m_currentWaypointId].position;
        m_navMeshAgent.isStopped = false;
        ++m_currentWaypointId;
        if (m_currentWaypointId >= m_patrolWaypoints.Count)
            m_currentWaypointId = 0;
    }


    //Shooting methods
    private void LockOnPlayer()
    {
        GameObject l_player = UtilsGyromitra.FindInstanceWithinRadius(this.gameObject, m_playerTag, m_locationRadius);

        if (l_player != null)
        {
            m_ray.enabled = true;

            transform.LookAt(l_player.transform);
            transform.eulerAngles = new Vector3(0f, transform.eulerAngles.y, transform.eulerAngles.z);

            Vector3 l_playerPos = l_player.transform.position;

            m_firePoint.forward = (l_playerPos - m_firePoint.position).normalized;

            if (m_timer >= m_warningTime && !m_alreadyLocked)
            {
                m_ray.material.color = Color.red;
                m_alreadyLocked = true;
            }

            Ray l_Ray = new Ray(m_firePoint.position, l_playerPos - m_firePoint.position);
            if (Physics.Raycast(l_Ray, out RaycastHit l_RaycastHit, 10000f, m_shootLayerMask.value))
            {
                float l_distance = l_RaycastHit.distance;
                m_ray.SetPosition(1, new Vector3(0.0f, 0.0f, l_distance));
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
        GameObject l_projectile = Instantiate(m_projectile, m_firePoint.position, m_firePoint.rotation);
        Rigidbody rb = l_projectile.GetComponent<Rigidbody>();
        rb.velocity = dir.normalized * m_projectileSpeed;
    }



    //private void OnCollisionEnter(Collision collision)
    //{
    //    if (collision.collider.tag == m_mushroomTag)
    //    {
    //        print("enemy mushroom collision");
    //        //m_navMeshAgent.isStopped = true;
    //        m_navMeshAgent.enabled = false;
    //        //SetBounceParameters
    //        //gameObject.transform.forward *= -1;
    //        gameObject.GetComponent<Rigidbody>().AddRelativeForce((gameObject.transform.position - collision.contacts[0].normal) * 3000);



    //    }
    //}

    //private void OnCollisionExit(Collision collision)
    //{
    //    if (collision.collider.tag == m_mushroomTag)
    //    {
    //        m_navMeshAgent.isStopped = false;
    //    }

    //}


    //private void OnTriggerEnter(Collider other)
    //{
    //    if (other.CompareTag(m_mushroomTag))
    //    {
    //        //print("enemy mushroom collision");

    //        //m_navMeshAgent.enabled = false;
    //        m_navMeshAgent.isStopped = true;
    //    }
    //}

    //public void SetBounceParameters(Vector3 dir, float power, float duration)
    //{
    //    m_bounceDirection = dir;
    //    m_bounceDirection.Normalize();
    //    m_bouncePower = power;
    //    m_bounceTimer = duration;
    //    m_bouncing = true;
    //}
}
