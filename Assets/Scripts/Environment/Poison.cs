using FMOD.Studio;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Poison : MonoBehaviour
{
    [SerializeField]
    private float m_currentDurationVenom;
    private float m_durationVenom;

    [SerializeField]
    private float m_currentVenomDamageTimer;
    private float m_venomDamageTimer;

    [SerializeField]
    private float m_damage;

    [SerializeField]
    private bool m_playerIsIn;

    [SerializeField]
    private string m_playerTag;

    [SerializeField]
    private CharacterControllerScript m_player;

    [SerializeField]
    private CharacterHP m_playerHealth;

    [Header("FMOD")]
    [SerializeField]
    private Transform m_soundEmitter;

    [SerializeField]
    private EventInstance m_eventPoison;

    private void Awake()
    {
        m_durationVenom = 3f;

        m_venomDamageTimer = 1f;
        m_currentVenomDamageTimer = m_venomDamageTimer;

        m_damage = 10f;

        m_playerIsIn = false;

        m_playerTag = UtilsGyromitra.SearchForTag("Player");

        m_eventPoison = FMODUnity.RuntimeManager.CreateInstance("event:/Personatge/14 - Enverinat");

        //m_player = GameObject.FindGameObjectWithTag(m_playerTag).GetComponent<CharacterControllerScript>();

        //m_playerHealth = m_player.gameObject.GetComponent<CharacterHP>();
    }

    private void OnEnable()
    {
        m_player.OnStopPoison += StopPoison;
    }
    private void OnDisable()
    {
        m_player.OnStopPoison -= StopPoison;
    }

    private void Update()
    {

        if (m_playerIsIn)
        {
            m_currentDurationVenom = m_durationVenom;

        } else
        {
            m_currentDurationVenom -= Time.deltaTime;
        }

        if (m_currentDurationVenom >= 0f)
        {
            // venom is active
            if (m_currentVenomDamageTimer >= 0f)
            {
                // timer
                m_currentVenomDamageTimer -= Time.deltaTime;

            } else
            {
                // do dmg
                m_currentVenomDamageTimer = m_venomDamageTimer;
                UtilsGyromitra.playSound(m_eventPoison, m_soundEmitter);
                m_playerHealth.Damage(m_damage);
            }
        }
        else
        {
            if(m_player.m_poisonedParticles.isActiveAndEnabled)
                m_player.m_poisonedParticles.Stop();
        } 
    }

    private void OnTriggerEnter(Collider other)
    {
        if (other.tag == m_playerTag)
        {
            m_playerIsIn = true;
            m_player.m_poisonedParticles.Play();
            m_soundEmitter = other.transform;
        }
    }

    private void OnTriggerExit(Collider other)
    {
        if (other.tag == m_playerTag)
        {
            m_playerIsIn = false;
        }
    }

    private void StopPoison()
    {
        m_player.m_poisonedParticles.Stop();
        m_playerIsIn = false;
        m_currentDurationVenom = 0f;
        m_currentVenomDamageTimer = m_venomDamageTimer;
    }
}
