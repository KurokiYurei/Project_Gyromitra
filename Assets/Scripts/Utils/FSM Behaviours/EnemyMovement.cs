using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.AI;

public class EnemyMovement : MonoBehaviour
{
    public NavMeshAgent m_navMeshAgent;

    public List<Transform> m_patrolWaypoints;
    int m_currentWaypointId = 0;

    // Start is called before the first frame update
    void Start()
    {
        m_navMeshAgent = gameObject.GetComponent<NavMeshAgent>();
        MoveToNextPatrolPosition();
    }

    // Update is called once per frame
    void Update()
    {
        if (!m_navMeshAgent.hasPath && m_navMeshAgent.pathStatus == NavMeshPathStatus.PathComplete)
            MoveToNextPatrolPosition();
    }

    void MoveToNextPatrolPosition()
    {
        m_navMeshAgent.destination = m_patrolWaypoints[m_currentWaypointId].position;
        m_navMeshAgent.isStopped = false;
        ++m_currentWaypointId;
        if (m_currentWaypointId >= m_patrolWaypoints.Count)
            m_currentWaypointId = 0;
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
