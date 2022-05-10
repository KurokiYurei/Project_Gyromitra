using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MovingPlatform : MonoBehaviour
{
    public List<Transform> m_waypoints;
    private int m_currentWaypoint;
    [SerializeField]
    private float m_speed = 0.1f;
    [SerializeField]
    private float m_waitingTime;
    private float m_timer;
    private bool m_moving;

    void Start()
    {
        m_currentWaypoint = -1;
        m_timer = m_waitingTime;
    }

    void Update()
    {
        /*
        if (!m_moving)
        {
            if (m_timer <= 0f)
            {
                GetNextWaypoint();
            }
            m_timer -= Time.deltaTime;
        }
        else
        {
            MoveToWaypoint();
        }*/
    }

    void GetNextWaypoint()
    {
        ++m_currentWaypoint;
        if (m_currentWaypoint >= m_waypoints.Count)
        {
            m_currentWaypoint = 0;
        }
        m_waypoints[m_currentWaypoint].transform.tag = "PlatformWaypoint";
        m_moving = true;
    }

    void MoveToWaypoint()
    {
        GameObject l_wayp = UtilsGyromitra.FindInstanceWithinRadius(gameObject, "PlatformWaypoint", 1f);
        transform.position = Vector3.MoveTowards(transform.position, m_waypoints[m_currentWaypoint].position, m_speed);
        if (l_wayp != null)
        {
            m_timer = m_waitingTime;
            m_moving = false;
            m_waypoints[m_currentWaypoint].transform.tag = "Untagged";
        }
    }

    private void OnTriggerEnter(Collider other)
    {
        print(other.tag);

        if (other.CompareTag(UtilsGyromitra.SearchForTag("Player")))
        {
            other.transform.GetComponent<CharacterController>().enabled = false;
            other.transform.SetParent(gameObject.transform);
            other.transform.GetComponent<CharacterController>().enabled = true;
        }
    }

    private void OnTriggerExit(Collider other)
    {
        print(other.tag);

        if (other.CompareTag(UtilsGyromitra.SearchForTag("Player")))
        {
            other.transform.GetComponent<CharacterController>().enabled = false;
            other.transform.parent = null;
            other.transform.GetComponent<CharacterController>().enabled = true;
        }
    }
}
