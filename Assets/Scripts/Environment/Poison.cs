using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Poison : MonoBehaviour
{

    [SerializeField]
    private float m_currentm_durationVenom;
    private float m_durationVenom;

    [SerializeField]
    private float m_currentVenomDamageTimer;
    private float m_venomDamageTimer;

    private float m_damage;

    [SerializeField]
    private bool m_playerIsIn;

    [SerializeField]
    private string m_playerTag;

    private CharacterHP m_player;

    private void Start()
    {
        m_durationVenom = 3f;
        m_currentm_durationVenom = m_durationVenom;

        m_venomDamageTimer = 1f;
        m_currentVenomDamageTimer = m_venomDamageTimer;

        m_damage = 5f;

        m_playerIsIn = false;
        m_playerTag = UtilsGyromitra.SearchForTag("Player");
    }

    private void Update()
    {
        
        if (m_playerIsIn)
        {
            m_currentm_durationVenom = m_durationVenom;

        } else
        {
            m_currentm_durationVenom -= Time.deltaTime;
        }

        if(m_currentm_durationVenom >= 0f)
        {

            m_currentm_durationVenom -= Time.deltaTime;


        } else
        {
            m_player = null;
            m_currentVenomDamageTimer = m_venomDamageTimer;
        }


    }

    private void OnTriggerEnter(Collider other)
    {
        if (other.tag == m_playerTag)
        {
            m_playerIsIn = true;
            m_player = other.transform.GetComponent<CharacterHP>();
        }
    }

    private void OnTriggerExit(Collider other)
    {
        if (other.tag == m_playerTag)
        {
            m_playerIsIn = false;
        }
    }

}
