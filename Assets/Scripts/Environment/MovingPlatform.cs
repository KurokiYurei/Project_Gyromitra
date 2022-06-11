using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MovingPlatform : MonoBehaviour
{
    public List<Transform> m_waypoints;
    private int m_currentWaypoint;
    private float m_speed;
    [SerializeField]
    private float m_timeToWaypoint = 0.1f;
    [SerializeField]
    private float m_waitingTime;
    private float m_timer;
    private bool m_moving;
    private bool m_colliding;
    private bool m_ready;
    private PlatformManager m_platfManager;

    void Awake()
    {
        m_platfManager = transform.GetComponentInParent<PlatformManager>();
    }
    void Start()
    {
        m_currentWaypoint = -1;
        m_timer = m_waitingTime;
    }

    private void OnEnable()
    {
        m_platfManager.OnMovePlatforms += Move; 
    }

    private void OnDisable()
    {
        m_platfManager.OnMovePlatforms -= Move;
    }

    void FixedUpdate()
    {
        if (!m_moving)
        {
            if (m_timer <= 0f)
            {
                if(!m_ready)
                    m_platfManager.m_readyPlatforms++;
                m_ready = true;               
            }
            m_timer -= Time.deltaTime;
        }
        else
        {
            MoveToWaypoint();
        }
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
        m_speed = Vector3.Distance(transform.position, m_waypoints[m_currentWaypoint].position) / m_timeToWaypoint;
    }

    void MoveToWaypoint()
    {
        if (Vector3.Distance(transform.position, m_waypoints[m_currentWaypoint].position) <= 1f)
        {
            m_timer = m_waitingTime;
            m_moving = false;
            m_waypoints[m_currentWaypoint].transform.tag = "Untagged";
        }
        transform.position = Vector3.MoveTowards(transform.position, m_waypoints[m_currentWaypoint].position, m_speed * Time.deltaTime);
    }

    private void OnTriggerEnter(Collider other)
    {
        if (other.CompareTag(UtilsGyromitra.SearchForTag("Player")) && !m_colliding)
        {
            m_colliding = true;
            other.transform.GetComponent<CharacterController>().enabled = false;
            other.transform.SetParent(gameObject.transform);
            other.transform.GetComponent<CharacterController>().enabled = true;
            other.transform.GetComponentInChildren<NewCameraController>().SetNormalCameraDamping(0f);
        }
    }

    private void OnTriggerExit(Collider other)
    {
        if (other.CompareTag(UtilsGyromitra.SearchForTag("Player")))
        {
            m_colliding = false;
            other.transform.GetComponent<CharacterController>().enabled = false;
            other.transform.parent = null;
            other.transform.GetComponent<CharacterController>().enabled = true;
            other.transform.GetComponentInChildren<NewCameraController>().SetNormalCameraDamping(0.5f);
        }
    }
    private void Move()
    {
        m_ready = false;
        GetNextWaypoint();
    }
}
