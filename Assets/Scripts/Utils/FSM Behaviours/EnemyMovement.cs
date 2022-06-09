using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.AI;

public class EnemyMovement : MonoBehaviour
{
    public NavMeshAgent m_navMeshAgent;

    public List<Transform> m_patrolWaypoints;
    int m_currentWaypointId = 0;

    public Animator m_animator;

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
        {
            m_animator.SetLayerWeight(1, 1);
            Vector3 dir = m_patrolWaypoints[m_currentWaypointId].position - transform.position;
            float direction = Vector3.Dot(dir, transform.forward);
            RotateToWaypoint();
            if (direction >= 1f)
            {
                MoveToNextPatrolPosition();
                m_animator.SetLayerWeight(1, 0);
            }
        }
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
    public void RotateToWaypoint()
    {
        Quaternion lookDirection = Quaternion.LookRotation(m_patrolWaypoints[m_currentWaypointId].position - transform.position);
        transform.rotation = Quaternion.Slerp(transform.rotation, lookDirection, Time.deltaTime / 2f);
        transform.eulerAngles = new Vector3(0f, transform.eulerAngles.y, transform.eulerAngles.z);
        bool isRight = GetRotateDirection(transform.rotation, lookDirection);
        m_animator.SetBool("TurnR", isRight);
        print(isRight);
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
