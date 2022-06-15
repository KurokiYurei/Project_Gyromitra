using FMOD.Studio;
using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.InputSystem;

public class CharacterHP : MonoBehaviour, IDamagable
{
    public float m_health { get; set; }

    private float m_maxHealth;
    private float m_minHealth;

    private float m_startTimeToRegen;

    [SerializeField]
    private float m_timerToRegen;

    [SerializeField]
    private float m_tickPerSecondHealth;

    private float m_healthPerSecond;

    [SerializeField]
    private UI_Manager m_ui;

    [Header("Health Shader")]
    [SerializeField]
    private Material m_quiverShader;
    [SerializeField]
    private float m_healthColorLimit;
    [SerializeField]
    private Color m_fullHealthColor;
    [SerializeField]
    private Color m_damagedHealthColor;

    [Header("FMOD")]
    [SerializeField]
    private Transform m_soundEmitter;

    [SerializeField]
    private EventInstance m_eventDie;

    [SerializeField]
    private EventInstance m_eventRegen;

    [SerializeField]
    private EventInstance m_eventLowHealth;

    private bool m_played;

    private void Awake()
    {
        m_eventDie = FMODUnity.RuntimeManager.CreateInstance("event:/Personatge/17 - Death sound");
        m_eventRegen = FMODUnity.RuntimeManager.CreateInstance("event:/Personatge/15 - Curació");
        m_eventLowHealth = FMODUnity.RuntimeManager.CreateInstance("event:/Personatge/16 - Low health");
        m_played = false;
    }

    void Start()
    {
        m_minHealth = 0f;
        m_maxHealth = 100f;

        m_timerToRegen = 2f;
        m_startTimeToRegen = 3f;
        m_healthPerSecond = 10f;
        m_tickPerSecondHealth = 1f;

        m_health = m_maxHealth;

        m_healthColorLimit = 90;
        m_fullHealthColor = new Color(9, 191, 0, 255)*3.0f;
        m_damagedHealthColor = new Color(99, 0, 74, 255)*3.0f;
    }

    void Update()
    {
        m_ui.SetHealth(m_health);

        m_quiverShader.SetFloat("_Fill", m_health/100f);

        if (m_health >= m_healthColorLimit) m_quiverShader.SetColor("_EmissionColor", m_fullHealthColor);
        else m_quiverShader.SetColor("_EmissionColor", m_damagedHealthColor);

        m_timerToRegen -= Time.deltaTime;

        if(m_health <= 50f && m_health >= 1f && !m_played)
        {
            UtilsGyromitra.playSound(m_eventLowHealth, m_soundEmitter);
            m_played = true;
        } else
        {
            m_played = false;
            UtilsGyromitra.stopSound(m_eventLowHealth);
        }

        if (m_timerToRegen <= 0f && m_health <= 100f)
        {
            m_tickPerSecondHealth -= Time.deltaTime;

            if (m_tickPerSecondHealth <= 0f)
            {
                Regen();
                m_tickPerSecondHealth = 1f;

            }
        }
    }

    /// <summary>
    /// Deal damage to the player
    /// </summary>
    /// <param name="damage"></param>
    public void Damage(float damage)
    {
        m_timerToRegen = m_startTimeToRegen;
        m_health -= damage;
        if (m_health <= m_minHealth)
        {
            transform.GetComponentInChildren<NewCameraController>().SetFollowAt(false);
            gameObject.GetComponent<PlayerInput>().enabled = false;
            StartCoroutine(waitToDie());
            UtilsGyromitra.playSound(m_eventDie, m_soundEmitter);
        }
    }

    IEnumerator waitToDie()
    {
        yield return new WaitForSeconds(0.5f);
        GameManagerScript.m_instance.RestartGame();
    }

    /// <summary>
    /// regen function
    /// </summary>
    public void Regen()
    {
        if(m_health >= m_maxHealth)
        {
            UtilsGyromitra.stopSound(m_eventRegen);
            m_health = m_maxHealth;
        }
        else
        {
            UtilsGyromitra.playSound(m_eventRegen, m_soundEmitter);
            m_health += m_healthPerSecond;
        }
    }

    /// <summary>
    /// reset hp of the player
    /// </summary>
    public void ResetHP()
    {
        m_health = m_maxHealth;
    }
}
