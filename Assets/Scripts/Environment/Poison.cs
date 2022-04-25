using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Poison : MonoBehaviour
{

    [SerializeField]
    private float m_CurrentTickPerSecond;

    private float m_tickPerSeconds;

    [SerializeField]
    private bool m_playerIsIn;

    [SerializeField]
    private string m_playerTag;

    private IDamagable m_player;

    private void Start()
    {
        m_tickPerSeconds = 0.5f;
        m_CurrentTickPerSecond = m_tickPerSeconds;
        m_playerIsIn = false;
        m_playerTag = UtilsGyromitra.SearchForTag("Player");
    }

    private void Update()
    {
        if (m_playerIsIn)
        {

            m_CurrentTickPerSecond -= Time.deltaTime;

            if (m_CurrentTickPerSecond <= 0)
            {
                m_player.Damage();
                ResetTimerVenom();

            }

        }
    }

    private void OnTriggerEnter(Collider other)
    {
        if (other.tag == m_playerTag)
        {
            m_playerIsIn = true;
            m_player = other.transform.GetComponent<IDamagable>();
        }
    }

    private void OnTriggerExit(Collider other)
    {
        if (other.tag == m_playerTag)
        {
            m_playerIsIn = false;
            ResetTimerVenom();
        }
    }

    public void ResetTimerVenom()
    {
        m_CurrentTickPerSecond = m_tickPerSeconds;
    }

}
