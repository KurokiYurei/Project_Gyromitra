using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.AI;


[RequireComponent(typeof(EnemyMovement))]
[RequireComponent(typeof(EnemyShoot))]

public class EnemyBehaviour : FiniteStateMachine
{
    public enum State { INITIAL, WANDER, ATTACK, STUN };

    public State m_currentState = State.INITIAL;
    
    private GameObject m_player;

    private EnemyMovement m_enemyMovement;
    private EnemyShoot m_enemyShoot;

    [Header("Attributes of the FSM")]
    [SerializeField]
    private float m_playerInRange;

    [SerializeField]
    private float m_playerOutOfRange;

    public bool m_mushroomImpact;

    private float m_stuntTime;

    private float m_antiPlayerSpam;

    private float m_antiPlayerSpamReset;

    [SerializeField]
    private float m_stuntTimeReset;

    [SerializeField]
    private LineRenderer m_lineRenderer;

    [Header("Material")]
    [SerializeField]
    private Material m_headMaterialVulnerable;

    [SerializeField]
    private Material m_headMaterialNormal;

    [SerializeField]
    private MeshRenderer m_headEnemy;

    [Header("Animation")]
    [SerializeField]
    private Animation m_animator;

    [SerializeField]
    private AnimationClip m_fall;

    [SerializeField]
    private AnimationClip m_getUp;

    public void SetMushroomHit(bool value)
    {
        m_mushroomImpact = value;
    }

    public bool GetMushroomHit()
    {
        return m_mushroomImpact;
    }

    private void Start()
    {
        m_enemyMovement = GetComponent<EnemyMovement>();
        m_enemyShoot = GetComponent<EnemyShoot>();

        m_enemyMovement.enabled = false;
        m_enemyShoot.enabled = false;

        m_playerInRange = 20f;
        m_playerOutOfRange = 30f;
        m_stuntTime = m_stuntTimeReset;

        m_antiPlayerSpam = m_antiPlayerSpamReset;   

    }

    private void Update()
    {
        
        switch(m_currentState)
        {

            case State.INITIAL:
                ChangeState(State.WANDER);
                break;

            case State.WANDER:

                m_antiPlayerSpam -= Time.deltaTime;

                // stun mushroom

                if (m_mushroomImpact && m_antiPlayerSpam <= 0f)
                {
                    ChangeState(State.STUN);
                    break;
                }

                // find player if in range

                m_player = UtilsGyromitra.FindInstanceWithinRadius(gameObject, UtilsGyromitra.SearchForTag("Player"), m_playerInRange);

                if (m_player != null && UtilsGyromitra.DistanceToTarget(this.gameObject, m_player) <= m_playerInRange )
                {

                    ChangeState(State.ATTACK);
                    break;
                }
                
                break;

            case State.ATTACK:

                m_antiPlayerSpam -= Time.deltaTime;

                // stun mushroom

                if (m_mushroomImpact && m_antiPlayerSpam <= 0f)
                {
                    ChangeState(State.STUN);
                    break;
                }

                // find player if out of range

                m_player = UtilsGyromitra.FindInstanceWithinRadius(gameObject, UtilsGyromitra.SearchForTag("Player"), m_playerInRange);

                if (m_player != null && UtilsGyromitra.DistanceToTarget(this.gameObject, m_player) >= m_playerOutOfRange)
                {
                    ChangeState(State.WANDER);
                    break;
                }
                break;

            case State.STUN:

                m_stuntTime -= Time.deltaTime;

                if (m_stuntTime <= 0f)
                {
                    m_player = UtilsGyromitra.FindInstanceWithinRadius(gameObject, UtilsGyromitra.SearchForTag("Player"), m_playerInRange);

                    // find player if in range

                    if (m_player != null && UtilsGyromitra.DistanceToTarget(this.gameObject, m_player) <= m_playerInRange)
                    {
                        ChangeState(State.ATTACK);
                        break;
                    }

                    // find player if out of range

                    if (m_player != null && UtilsGyromitra.DistanceToTarget(this.gameObject, m_player) >= m_playerOutOfRange)
                    {
                        ChangeState(State.WANDER);
                        break;
                    }
                }

                break;
        }
    }

    private void ChangeState(State l_newState)
    {
        // exit logic
        switch (m_currentState)
        {
            case State.WANDER:
                m_enemyMovement.enabled = false;
                break;

            case State.ATTACK:
                m_enemyShoot.enabled = false;
                m_lineRenderer.enabled = false;
                m_enemyShoot.setPlayer(null);
                break;

            case State.STUN:    
                SetMushroomHit(false);
                m_stuntTime = m_stuntTimeReset;
                m_headEnemy.material = m_headMaterialNormal;
                m_animator.Play(m_getUp.name);
                break;

        }

        // enter logic
        switch (l_newState)
        {
            case State.WANDER:
                m_enemyMovement.enabled = true;
                break;  

            case State.ATTACK:
                m_enemyShoot.enabled = true;
                m_lineRenderer.enabled = true;
                m_enemyShoot.setPlayer(m_player);
                break;
                    
            case State.STUN:
                m_headEnemy.material = m_headMaterialVulnerable;
                m_animator.Play(m_fall.name);
                m_antiPlayerSpam = m_antiPlayerSpamReset;
                break;

        }
        m_currentState = l_newState;
    }

}
